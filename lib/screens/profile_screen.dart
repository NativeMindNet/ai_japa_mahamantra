import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';

/// Экран профиля пользователя с интеграцией Magento
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Загружаем профиль при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.isLoggedIn &&
          profileProvider.currentProfile == null) {
        profileProvider.loadCurrentProfile();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (!profileProvider.isLoggedIn) {
          return const _LoginScreen();
        }

        if (profileProvider.isLoading &&
            profileProvider.currentProfile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (profileProvider.currentProfile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Профиль')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    profileProvider.error ?? 'Не удалось загрузить профиль',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileProvider.loadCurrentProfile(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = profileProvider.currentProfile!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context, profileProvider),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Профиль'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Статистика'),
                Tab(icon: Icon(Icons.settings), text: 'Настройки'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _ProfileTab(profile: profile),
              _StatisticsTab(profile: profile),
              _SettingsTab(profile: profile),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.logout();
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

/// Вкладка профиля
class _ProfileTab extends StatelessWidget {
  final UserProfile profile;

  const _ProfileTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Аватар
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.firstName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 48),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () => _showAvatarPicker(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Имя
          Text(
            profile.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            profile.email,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Карточки информации
          _InfoCard(
            icon: Icons.calendar_today,
            title: 'Дата регистрации',
            value: profile.createdAt != null
                ? _formatDate(profile.createdAt!)
                : 'Не указана',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.language,
            title: 'Язык',
            value: profile.language ?? 'Не указан',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.access_time,
            title: 'Часовой пояс',
            value: profile.timezone ?? 'Не указан',
          ),
          const SizedBox(height: 24),

          // Кнопка редактирования
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditDialog(context, profile),
              icon: const Icon(Icons.edit),
              label: const Text('Редактировать профиль'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showAvatarPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить аватар'),
        content: const Text(
          'Функция загрузки аватара будет доступна в следующей версии.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserProfile profile) {
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Фамилия',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final updatedProfile = profile.copyWith(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
              );
              context.read<ProfileProvider>().updateProfile(updatedProfile);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

/// Вкладка статистики
class _StatisticsTab extends StatelessWidget {
  final UserProfile profile;

  const _StatisticsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = profile.statistics ?? UserStatistics();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Уровень и опыт
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Уровень ${stats.level}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${stats.experience} XP',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (stats.experience % 1000) / 1000,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${1000 - (stats.experience % 1000)} XP до следующего уровня',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Основная статистика
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.offline_bolt,
                  title: 'Мантры',
                  value: stats.totalMantras.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_available,
                  title: 'Сессии',
                  value: stats.totalSessions.toString(),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  title: 'Серия дней',
                  value: stats.currentStreak.toString(),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer,
                  title: 'Минут',
                  value: stats.totalMinutes.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  title: 'Достижения',
                  value: stats.achievementsCount.toString(),
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  title: 'Лучшая серия',
                  value: stats.bestStreak.toString(),
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Глобальный рейтинг
          if (stats.globalRank != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.leaderboard, color: Colors.amber),
                title: const Text('Глобальный рейтинг'),
                trailing: Text(
                  '#${stats.globalRank}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Вкладка настроек джапы
class _SettingsTab extends StatefulWidget {
  final UserProfile profile;

  const _SettingsTab({required this.profile});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late JapaPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.profile.japaPreferences ?? JapaPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки практики',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Ежедневная цель
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Ежедневная цель'),
              subtitle: Text('${_preferences.dailyGoal} мантр'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showDailyGoalDialog(context),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Количество кругов
          Card(
            child: ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Кругов малы'),
              subtitle: Text('${_preferences.malaRounds} кругов'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showMalaRoundsDialog(context),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Переключатели
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Напоминания'),
            subtitle: const Text('Ежедневные уведомления'),
            value: _preferences.remindersEnabled,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(remindersEnabled: value);
              });
              _savePreferences();
            },
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Звук бусин'),
            subtitle: const Text('Звук при переключении бусин'),
            value: _preferences.beadSoundEnabled,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(beadSoundEnabled: value);
              });
              _savePreferences();
            },
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Вибрация'),
            subtitle: const Text('Вибрация при переключении бусин'),
            value: _preferences.vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(vibrationEnabled: value);
              });
              _savePreferences();
            },
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            secondary: const Icon(Icons.cloud_sync),
            title: const Text('Автосинхронизация'),
            subtitle: const Text('Автоматическая синхронизация с облаком'),
            value: _preferences.autoSync,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(autoSync: value);
              });
              _savePreferences();
            },
          ),
        ],
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _preferences.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ежедневная цель'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Количество мантр',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 108;
              setState(() {
                _preferences = _preferences.copyWith(dailyGoal: value);
              });
              _savePreferences();
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showMalaRoundsDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _preferences.malaRounds.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Количество кругов'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Кругов малы',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 1;
              setState(() {
                _preferences = _preferences.copyWith(malaRounds: value);
              });
              _savePreferences();
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _savePreferences() {
    context.read<ProfileProvider>().updateJapaPreferences(_preferences);
  }
}

/// Экран входа
class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),

                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите имя';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите фамилию';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      }
                      if (!value.contains('@')) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      if (value.length < 6) {
                        return 'Пароль должен быть не менее 6 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  if (profileProvider.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        profileProvider.error!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton(
                    onPressed: profileProvider.isLoading
                        ? null
                        : () => _submitForm(context, profileProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: profileProvider.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            _isLogin ? 'Войти' : 'Зарегистрироваться',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                      profileProvider.clearError();
                    },
                    child: Text(
                      _isLogin
                          ? 'Нет аккаунта? Зарегистрироваться'
                          : 'Уже есть аккаунт? Войти',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    ProfileProvider profileProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool success;
    if (_isLogin) {
      success = await profileProvider.login(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      success = await profileProvider.register(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
    }

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Вход выполнен' : 'Регистрация завершена'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Виджет карточки информации
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Виджет карточки статистики
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
