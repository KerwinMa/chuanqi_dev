@echo off

rem -------------------------------------------
rem ���ƽű���windows�汾��
rem -------------------------------------------

rem ��Ŀ¼
set COOKIE=chuanqi_mmo

set NODE=1
set GAME_NODE_NAME=chuanqi_game_%NODE%@127.0.0.1
set GAME_CONFIG_FILE=normal_1

set SMP=auto
set ERL_PROCESSES=102400
set MMAKE_PROCESS=50

:fun_wait_input
	set inp=
	echo.
	echo ===============================
	echo make:�������˴���
	echo update:�������´���
	echo start:�������з�����
	echo debug:�������з�����(����start������������ʱ����������ˣ��鿴����)
	echo game:������Ϸ��
	echo cross:�������
	echo clean:����beam�ļ�
	echo clean_log:������־
	echo all:kill���������롢����
	echo kill:kill����
	echo quit:�������п���̨
	echo -------------------------------
	set /p inp=������ָ�
	echo -------------------------------
	goto fun_run

:where_to_go
	rem �����Ƿ���������в���
	if [%1]==[] goto fun_wait_input
	goto end

:fun_run
	if [%inp%]==[all] goto fun_all
	if [%inp%]==[make] goto fun_make
	if [%inp%]==[update] goto fun_update
	if [%inp%]==[start] goto fun_start_all
	if [%inp%]==[game] goto fun_start_game
	if [%inp%]==[clean] goto fun_clean_beam
	if [%inp%]==[clean_log] goto fun_clean_log
	if [%inp%]==[kill] goto fun_kill
	if [%inp%]==[quit] goto end
	goto where_to_go

:fun_all
	taskkill /F /IM werl.exe
	cd ../ebin
	del *.beam
	cd ../logs
	rd /s /q flash
	rd /s /q cross
	rd /s /q game
	rd /s /q mgr
	cd ..
	erl -pa ./ebin -noshell -eval "mmake:all(%MMAKE_PROCESS%), init:stop()"
	cd config
	start werl +P %ERL_PROCESSES% -smp %SMP% -pa ../ebin -name %GAME_NODE_NAME% -setcookie %COOKIE% -boot start_sasl -config %GAME_CONFIG_FILE% -s main server_start -- node_normal
	goto where_to_go

:fun_make
	echo �Եȼ�����
	cd ../ebin
	del *.beam
	cd ..
	erl -pa ./ebin -noshell -eval "mmake:all(%MMAKE_PROCESS%), init:stop()"
	cd config
	goto where_to_go

:fun_update
	echo �Եȼ�����
	cd ..
	rem erl -pa ./ebin -make
	erl -pa ./ebin -noshell -eval "mmake:all(%MMAKE_PROCESS%), init:stop()" 
	cd config
	goto where_to_go

:fun_start_all
	cd ../config
	start werl +P %ERL_PROCESSES% -smp %SMP% -pa ../ebin -name %GAME_NODE_NAME% -setcookie %COOKIE% -boot start_sasl -config %GAME_CONFIG_FILE% -s main server_start -- node_normal
	goto where_to_go

:fun_start_game
	cd ../config
	start werl +P %ERL_PROCESSES% -smp %SMP% -pa ../ebin -name %GAME_NODE_NAME% -setcookie %COOKIE% -boot start_sasl -config %GAME_CONFIG_FILE% -s main server_start -- node_normal
	goto where_to_go

:fun_start_cross
	cd ../config
	start werl +P %ERL_PROCESSES% -smp %SMP% -env ERL_MAX_PORTS 5000 -pa ../ebin -name %CROSS_NODE_NAME% -setcookie %COOKIE% -boot start_sasl -config %CROSS_CONFIG_FILE% -s main server_start -s reloader
	goto where_to_go

:fun_clean_beam
	cd ../ebin
	del *.beam
	goto where_to_go

:fun_clean_log
	cd ../logs
	rd /s /q flash
	rd /s /q cross
	rd /s /q game
	rd /s /q mgr
	cd ../config
	goto where_to_go

:fun_kill
	taskkill /F /IM werl.exe
	goto where_to_go

:end