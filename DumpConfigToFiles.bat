@echo off

::Вывод кириллицы:
chcp 65001 > nul

::Для работы с переменными окружения bat файла:
setlocal enabledelayedexpansion

::----Изменяемые параметры----

    ::Версия платформы 1С:
    set version1C=8.3.25.1560

    ::Имя пользователя 1С
    set userName=Администратор

    ::Пароль пользователя 1С:
    set userpassword=

    ::Путь к папке с файловой базой:
    set localPathВase=C:\Users\admin\Documents\Работа\Базы 1С\Управление торговлей (демо)

    ::Рабочая папка для батника:
    set localPathApp=C:\tmp1C

    ::Имя файла со списком выгружаемых объектов, каждый объект выводить с новой строки:
    set nameListFile=list.txt
    ::Пример содержимого файла:
    ::Справочник.Валюты
    ::Справочник.Валюты.Форма.ФормаЭлемента

::----Неизменяемые параметры окружения----

    ::Путь к папке с 1Cv8.exe:
    set Path1Cexe=%ProgramFiles%\1cv8\%version1C%\bin\1cv8.exe

    ::Полный путь к файлу со списком выгружаемых объектов:
    set pathListFile=%localPathApp%\%nameListFile%

    ::Папка, куда будут выгружены файлы, пример результата выгрузки:
    set localPathToSrc=%localPathApp%\src

    ::Файл для вывода системных сообщений 1С:
    set logFile_DumpConfigToFiles=%localPathApp%\logFile_DumpConfigToFiles.log

    ::Режим создания структуры папок:
    set isCreateDirectory=false

::BEGIN--------------------------------

    ::Поиcк и создание рабочей папки "%localPathApp%":
    if not EXIST "%localPathApp%" (
        md %localPathApp%
        if %ERRORLEVEL% neq 0 (
            echo Завершено с ошибками: !error_message!
            goto END_ERRORLEVEL
        )
        echo Папка "%localPathApp%" создана
    ) else (
        echo Найдена папка "%localPathApp%"
    )

    ::Переход в рабочую папку:
    cd "%localPathApp%"

    ::Поиcк и создание папки %localPathToSrc% для выгрузки файлов:
    if not EXIST "%localPathToSrc%" (
        md "%localPathToSrc%"
        if %ERRORLEVEL% neq 0 (
            echo Завершено с ошибками: !error_message!
            goto END_ERRORLEVEL
        )
        echo Папка "%localPathToSrc%" создана
    ) else (
        echo Найдена папка "%localPathToSrc%"
    )

    ::Поиcк фала %nameListFile% со списком выгружаемых объектов
    ::Если файла нет, создаем его и записываем две записи:
    if not EXIST "%pathListFile%" (

        @echo ON
        echo Справочник.Валюты>"%pathListFile%"
        echo Справочник.Валюты.Форма.ФормаЭлемента>>"%pathListFile%"
        @echo OFF

        if %ERRORLEVEL% neq 0 (
            echo Завершено с ошибками: Файл списка не создан: "%pathListFile%"
            goto END_ERRORLEVELs
        )
        echo Создан файл %nameListFile% c выгружаемыми объектами
        echo Справочник.Валюты
        echo Справочник.Валюты.Форма.ФормаЭлемента
    ) else (
        echo Найден файл "%nameListFile%"
    )

    echo Старт выгрузки объектов

    "%Path1Cexe%" ^
        DESIGNER ^
        /AppAutoCheckVersion+ ^
        /F "%localPathВase%" ^
        /N "%userName%" ^
        /P "%userpassword%" ^
        /DisableStartupMessages ^
        /DisableStartupDialogs ^
        /DumpConfigToFiles "%localPathToSrc%" ^
            -listFile "%pathListFile%" ^
            -Format "Hierarchical" ^
        /Out "%logFile_DumpConfigToFiles%" ^
            -NoTruncate

    if %ERRORLEVEL% neq 0 (
        echo Завершено с ошибками: !error_message!
        goto END_ERRORLEVEL
    )

::END BEGIN--------------------------------

echo Успешное завершение.
pause
goto END_EXIT

:END_ERRORLEVEL
echo Произошли ошибки в ходе выполнения bat пакета!
type "%logFile_DumpConfigToFiles%"
pause

:END_EXIT
exit /b 0

ENDLOCAL