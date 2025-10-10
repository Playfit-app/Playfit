import 'package:flutter/material.dart';
import 'package:playfit/services/log_service.dart';

class LogConsole extends StatelessWidget {
  const LogConsole({super.key});

  @override
  Widget build(BuildContext context) {
    final logService = LogService.instance;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Debug Logs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear logs',
                  onPressed: logService.clear,
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<List<LogEntry>>(
              valueListenable: logService.entries,
              builder: (context, entries, _) {
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No log entries yet.\nActions you perform here will appear in real time.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _levelBackground(entry.level),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    entry.formattedTimestamp,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _levelColor(entry.level),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      entry.level.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.message,
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (entry.error != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Error: ${entry.error}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                              if (entry.stackTrace != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  entry.stackTrace.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blueGrey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
    }
  }

  Color _levelBackground(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blueGrey.withValues(alpha: 0.08);
      case LogLevel.info:
        return Colors.blue.withValues(alpha: 0.08);
      case LogLevel.warning:
        return Colors.orange.withValues(alpha: 0.12);
      case LogLevel.error:
        return Colors.red.withValues(alpha: 0.12);
    }
  }
}
