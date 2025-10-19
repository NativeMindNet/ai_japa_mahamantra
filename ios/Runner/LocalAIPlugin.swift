import Flutter
import UIKit
import Foundation

/**
 * LocalAIPlugin - плагин для работы с локальной AI моделью на iOS
 * 
 * Использует llama.cpp через C++ мост для максимальной производительности
 * Поддерживает GPU ускорение через Metal на iOS
 */
@available(iOS 13.0, *)
public class LocalAIPlugin: NSObject, FlutterPlugin {
    private var modelLoaded = false
    private var modelPath: String?
    private let queue = DispatchQueue(label: "ai.japa.local_ai", qos: .userInitiated)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "ai_japa_mahamantra/local_ai",
            binaryMessenger: registrar.messenger()
        )
        let instance = LocalAIPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        NSLog("[LocalAIPlugin] Плагин зарегистрирован")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(call: call, result: result)
        case "generate":
            generate(call: call, result: result)
        case "dispose":
            dispose(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Инициализация модели
    
    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let args = call.arguments as? [String: Any],
                  let modelPath = args["modelPath"] as? String else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "Отсутствуют обязательные аргументы",
                        details: nil
                    ))
                }
                return
            }
            
            let nThreads = args["nThreads"] as? Int ?? 4
            let nGpuLayers = args["nGpuLayers"] as? Int ?? 0
            let contextSize = args["contextSize"] as? Int ?? 2048
            
            // Проверяем существование файла модели
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: modelPath) else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "MODEL_NOT_FOUND",
                        message: "Модель не найдена по пути: \(modelPath)",
                        details: nil
                    ))
                }
                return
            }
            
            self.modelPath = modelPath
            
            // Инициализируем модель через C++ мост
            let success = llama_init_model(
                modelPath,
                Int32(nThreads),
                Int32(nGpuLayers),
                Int32(contextSize)
            )
            
            self.modelLoaded = success
            
            DispatchQueue.main.async {
                if success {
                    NSLog("[LocalAIPlugin] Модель инициализирована: \(modelPath)")
                    NSLog("[LocalAIPlugin] GPU слои: \(nGpuLayers), потоки: \(nThreads)")
                    result(true)
                } else {
                    result(FlutterError(
                        code: "INIT_FAILED",
                        message: "Не удалось инициализировать модель",
                        details: nil
                    ))
                }
            }
        }
    }
    
    // MARK: - Генерация текста
    
    private func generate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard modelLoaded else {
            result(FlutterError(
                code: "MODEL_NOT_LOADED",
                message: "Модель не загружена",
                details: nil
            ))
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let args = call.arguments as? [String: Any],
                  let prompt = args["prompt"] as? String else {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "Отсутствует промпт",
                        details: nil
                    ))
                }
                return
            }
            
            let temperature = (args["temperature"] as? Double) ?? 0.8
            let topP = (args["topP"] as? Double) ?? 0.95
            let topK = (args["topK"] as? Int) ?? 40
            let maxTokens = (args["maxTokens"] as? Int) ?? 512
            
            // Генерируем через C++ мост
            var outputBuffer = [CChar](repeating: 0, count: 4096)
            let success = llama_generate(
                prompt,
                Float(temperature),
                Float(topP),
                Int32(topK),
                Int32(maxTokens),
                &outputBuffer,
                Int32(outputBuffer.count)
            )
            
            DispatchQueue.main.async {
                if success {
                    let response = String(cString: outputBuffer)
                    NSLog("[LocalAIPlugin] Генерация завершена: \(response.count) символов")
                    result(response)
                } else {
                    result(FlutterError(
                        code: "GENERATION_FAILED",
                        message: "Не удалось сгенерировать ответ",
                        details: nil
                    ))
                }
            }
        }
    }
    
    // MARK: - Освобождение ресурсов
    
    private func dispose(result: @escaping FlutterResult) {
        if modelLoaded {
            llama_free_model()
            modelLoaded = false
            modelPath = nil
            NSLog("[LocalAIPlugin] Модель выгружена из памяти")
        }
        result(nil)
    }
}

// MARK: - C++ мост (заглушки для компиляции)

// Эти функции будут реализованы в llama_cpp_bridge.cpp
@_silgen_name("llama_init_model")
func llama_init_model(_ modelPath: String, _ nThreads: Int32, _ nGpuLayers: Int32, _ contextSize: Int32) -> Bool

@_silgen_name("llama_generate")
func llama_generate(_ prompt: String, _ temperature: Float, _ topP: Float, _ topK: Int32, _ maxTokens: Int32, _ output: UnsafeMutablePointer<CChar>, _ outputSize: Int32) -> Bool

@_silgen_name("llama_free_model")
func llama_free_model()

