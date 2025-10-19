package com.example.ai_japa_mahamantra

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.File

/**
 * LocalAIPlugin - плагин для работы с локальной AI моделью через llama.cpp
 * 
 * Интеграция с llama.cpp через JNI для максимальной производительности
 * Поддерживает GPU ускорение через Vulkan на Android
 */
class LocalAIPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var modelLoaded = false
    private var modelPath: String? = null
    
    // Корутина для асинхронной обработки
    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    
    companion object {
        const val TAG = "LocalAIPlugin"
        const val CHANNEL_NAME = "ai_japa_mahamantra/local_ai"
        
        // Загружаем нативную библиотеку llama.cpp
        init {
            try {
                System.loadLibrary("llama")
                System.loadLibrary("llama_android")
                Log.d(TAG, "Нативные библиотеки llama.cpp загружены успешно")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "Ошибка загрузки нативных библиотек: ${e.message}")
            }
        }
    }
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        Log.d(TAG, "LocalAIPlugin подключен к движку Flutter")
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
        if (modelLoaded) {
            nativeFreeModel()
        }
        Log.d(TAG, "LocalAIPlugin отключен от движка Flutter")
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "generate" -> generate(call, result)
            "dispose" -> dispose(result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * Инициализирует модель
     */
    private fun initialize(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val modelPath = call.argument<String>("modelPath")
                val nThreads = call.argument<Int>("nThreads") ?: 4
                val nGpuLayers = call.argument<Int>("nGpuLayers") ?: 0
                val contextSize = call.argument<Int>("contextSize") ?: 2048
                
                if (modelPath == null || !File(modelPath).exists()) {
                    withContext(Dispatchers.Main) {
                        result.error("MODEL_NOT_FOUND", "Модель не найдена по пути: $modelPath", null)
                    }
                    return@launch
                }
                
                this@LocalAIPlugin.modelPath = modelPath
                
                // Инициализируем нативную модель
                val success = nativeInitModel(
                    modelPath = modelPath,
                    nThreads = nThreads,
                    nGpuLayers = nGpuLayers,
                    contextSize = contextSize
                )
                
                modelLoaded = success
                
                withContext(Dispatchers.Main) {
                    if (success) {
                        Log.i(TAG, "Модель инициализирована: $modelPath (GPU слои: $nGpuLayers, потоки: $nThreads)")
                        result.success(true)
                    } else {
                        result.error("INIT_FAILED", "Не удалось инициализировать модель", null)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Ошибка инициализации: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("INIT_ERROR", e.message, null)
                }
            }
        }
    }
    
    /**
     * Генерирует ответ модели
     */
    private fun generate(call: MethodCall, result: Result) {
        if (!modelLoaded) {
            result.error("MODEL_NOT_LOADED", "Модель не загружена", null)
            return
        }
        
        scope.launch {
            try {
                val prompt = call.argument<String>("prompt") ?: ""
                val temperature = call.argument<Double>("temperature") ?: 0.8
                val topP = call.argument<Double>("topP") ?: 0.95
                val topK = call.argument<Int>("topK") ?: 40
                val maxTokens = call.argument<Int>("maxTokens") ?: 512
                
                // Генерируем ответ через нативный код
                val response = nativeGenerate(
                    prompt = prompt,
                    temperature = temperature.toFloat(),
                    topP = topP.toFloat(),
                    topK = topK,
                    maxTokens = maxTokens
                )
                
                withContext(Dispatchers.Main) {
                    if (response != null) {
                        Log.d(TAG, "Генерация завершена: ${response.length} символов")
                        result.success(response)
                    } else {
                        result.error("GENERATION_FAILED", "Не удалось сгенерировать ответ", null)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Ошибка генерации: ${e.message}", e)
                withContext(Dispatchers.Main) {
                    result.error("GENERATION_ERROR", e.message, null)
                }
            }
        }
    }
    
    /**
     * Освобождает ресурсы модели
     */
    private fun dispose(result: Result) {
        if (modelLoaded) {
            nativeFreeModel()
            modelLoaded = false
            modelPath = null
            Log.i(TAG, "Модель выгружена из памяти")
        }
        result.success(null)
    }
    
    // ========== Нативные методы (JNI) ==========
    
    /**
     * Инициализирует модель через JNI
     */
    private external fun nativeInitModel(
        modelPath: String,
        nThreads: Int,
        nGpuLayers: Int,
        contextSize: Int
    ): Boolean
    
    /**
     * Генерирует текст через JNI
     */
    private external fun nativeGenerate(
        prompt: String,
        temperature: Float,
        topP: Float,
        topK: Int,
        maxTokens: Int
    ): String?
    
    /**
     * Освобождает модель через JNI
     */
    private external fun nativeFreeModel()
}

