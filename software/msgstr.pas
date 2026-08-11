unit msgstr;

{$mode objfpc}{$H+}

interface

resourcestring
  STR_CHECK_SETTINGS     = 'Проверьте настройки';
  STR_READING_FLASH      = 'Читаю флэшку...';
  STR_WRITING_FLASH      = 'Записываю флэшку...';
  STR_WRITING_FLASH_WCHK = 'Записываю флэшку с проверкой...';
  STR_CONNECTION_ERROR   = 'Ошибка подключения к ';
  STR_SET_SPEED_ERROR    = 'Ошибка установки скорости SPI';
  STR_WRONG_BYTES_READ   = 'Количество прочитанных байт не равно размеру флэшки';
  STR_WRONG_BYTES_WRITE  = 'Количество записанных байт не равно размеру флэшки';
  STR_WRONG_FILE_SIZE    = 'Размер файла больше размера чипа';
  STR_ERASING_FLASH      = 'Стираю флэшку...';
  STR_DONE               = 'Готово';
  STR_BLOCK_EN           = 'Возможно включена защита на запись. Нажмите кнопку "Снять защиту" и сверьтесь с даташитом';
  STR_VERIFY_ERROR       = 'Ошибка сравнения по адресу: ';
  STR_VERIFY             = 'Проверяю флэшку...';
  STR_TIME               = 'Время выполнения: ';
  STR_USER_CANCEL        = 'Прервано пользователем';
  STR_NO_EEPROM_SUPPORT  = 'Данная версия прошивки не поддерживается!';
  STR_MINI_EEPROM_SUPPORT= 'Данная версия прошивки не поддерживает I2C и MW!';
  STR_I2C_NO_ANSWER      = 'Микросхема не отвечает';
  STR_COMBO_WARN         = 'Чип будет стерт и перезаписан. Продолжить?';
  STR_SEARCH_HEX         = 'Поиск HEX значения';
  STR_GOTO_ADDR          = 'Перейти по адресу';
  STR_NEW_SREG           = 'Стало Sreg: ';
  STR_OLD_SREG           = 'Было Sreg: ';
  STR_START_WRITE        = 'Начать запись?';
  STR_START_ERASE        = 'Точно стереть чип?';
  STR_45PAGE_STD         = 'Установлен стандартный размер страницы';
  STR_45PAGE_POWEROF2    = 'Установлен размер страницы кратный двум!';
  STR_ID_UNKNOWN         = '(Неизвестно)';
  STR_SPECIFY_HEX        = 'Укажите шестнадцатеричные числа';
  STR_NOT_FOUND_HEX      = 'Значение не найдено';
  STR_USB_TIMEOUT        = 'USB_control_msg отвалился по таймауту!';
  STR_SIZE               = 'Размер: ';
  STR_CHANGED            = 'Изменен';
  STR_CURR_HW            = 'Используется программатор: ';
  STR_USING_SCRIPT       = 'Используется скрипт: ';
  STR_DLG_SAVEFILE       = 'Сохранить изменения?';
  STR_DLG_FILECHGD       = 'файл изменён';
  STR_SCRIPT_NO_SECTION  = 'Нет секции: ';
  STR_SCRIPT_SEL_SECTION = 'Выберите секцию';
  STR_SCRIPT_RUN_SECTION = 'Выполняется секция: ';
  STR_ERASE_NOTICE       = 'Процесс может длиться больше минуты на больших флешках!';

  // --- FlashBridge / new features (added) ---
  STR_FB_REC_OUT          = 'Chip needs %dmV, out of VIO range (1200-3300)';
  STR_FB_REC_LOW          = 'Recommended %dmV (below 1.4V will use timed hold), click Set to apply';
  STR_FB_REC              = 'Recommended %dmV, click Set to apply';
  STR_FB_BTN_CONNECT      = 'Connect';
  STR_FB_BTN_DISCONNECT   = 'Disconnect';
  STR_FB_NOT_CONNECTED    = 'Not connected';
  STR_FB_CONNECTING       = 'Connecting %s ...';
  STR_FB_DETECTING        = 'Detecting COM port...';
  STR_FB_NOT_FOUND        = 'FlashBridge not found';
  STR_FB_CONNECTED        = 'Connected (%s)';
  STR_FB_HOLDING          = 'Holding %dmV | %ds left';
  STR_FB_BLOCKED          = 'Voltage cannot be changed during hold';
  STR_FB_FORMAT_ERR       = 'Invalid voltage format';
  STR_FB_RANGE            = 'Range 1200-3300mV';
  STR_FB_HOLD_SENT        = 'Sent %dmV(%ds), communication may be interrupted';
  STR_FB_SET_OK           = 'Set to %dmV';
  STR_FB_RESTORED         = 'Restored V %s';
  STR_FB_EXPIRED          = 'Expired, please reconnect to confirm';
  STR_FB_EXPIRED_AUTO     = 'Expired, voltage should have auto-restored, reconnect to confirm';
  STR_FB_DISCONNECTED     = 'Disconnected (no response)';
  STR_FB_NO_RESP          = 'No response: %s';
  STR_SPI_FREQ_TITLE      = 'SPI Clock Frequency';
  STR_SPI_FREQ_PROMPT     = 'Enter SPI clock frequency in Hz (0 = use preset). Supported range 218.75KHz-60MHz:';
  STR_SPI_FREQ_PRESET     = 'SPI using preset frequency';
  STR_SPI_FREQ_RANGE      = 'SPI frequency out of range (218.75KHz-60MHz), not set';
  STR_SPI_FREQ_SET        = 'SPI custom frequency: %d Hz';
  STR_USB_FS              = 'CH347 USB: Full Speed';
  STR_USB_HS              = 'CH347 USB: High Speed';
  STR_USB_SS              = 'CH347 USB: Super Speed';
  STR_USB_UNK             = 'CH347 USB: speed=%d';
  STR_SPI_CFG             = 'SPI cfg: mode=%d clock=%d byteOrder=%d cs=%d';
  STR_SPI_CFG_FAIL        = 'SPI GetCfg failed';
  STR_I2C_SCAN            = 'I2C bus scan ...';
  STR_I2C_SCAN_FOUND      = 'Found %d device(s): %s';
  STR_I2C_SCAN_NONE       = 'No I2C device found';
  STR_I2C_SCAN_TITLE      = 'I2C devices found:';
  STR_I2C_BM_READ         = 'I2C Benchmark read %d bytes * %d cycles';
  STR_I2C_BM_WRITE        = 'I2C Benchmark write %d bytes * %d cycles (data restored after)';
  STR_I2C_BM_RESTORED     = 'I2C Benchmark: original data restored and verified';
  STR_I2C_BM_RESTORE_FAIL = 'I2C Benchmark: RESTORE FAILED - check chip';
  STR_BTN_OK              = 'OK';
  STR_BTN_CANCEL          = 'Cancel';

implementation

end.

