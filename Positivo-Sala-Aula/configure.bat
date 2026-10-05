REM Fontes:
REM 1. https://ss64.com/nt/chcp.html
REM 2. https://learn.microsoft.com/pt-br/windows-server/administration/windows-commands/chcp
REM Objetivo: Mostrar corrtamente as palavras na mensagem do shutdown

chcp 860

REM Deletar usuário anos_iniciais

net user anos_iniciais /delete

REM Desativar hibernação, evitado o bug do notebook hibernar e não volta.
powercfg.exe /hibernate off 

mkdir C:\Proati-Scripts\Positivo-Sala-Aula\

xcopy /e . C:\Proati-Scripts\Positivo-Sala-Aula\


REM Fonte: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create
REM Objetivo: Criar tarefa para ser acionada quando o sistema é iniciado (ligado).
schtasks /create /sc ONSTART /ru System /tn "Limpeza Perfis Inativos" /tr C:\Proati-Scripts\Positivo-Sala-Aula\scripts\limpeza-perfis.bat


REM Fonte: https://www.geeksforgeeks.org/techtips/how-to-run-powershell-script-from-cmd/
REM Corrigido por Gemini
REM Objetivo: Fazer que a tarefa criada anteriormente seja executada na bateria e que não seja Interrompida quando estiver na bateria.
REM Afinal, é um notebook.
powershell -Command "$t = Get-ScheduledTask -TaskName 'Limpeza Perfis Inativos'; $t.Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Set-ScheduledTask -InputObject $t"


REM Fontes:
REM 1: https://learn.microsoft.com/pt-br/windows-server/administration/windows-commands/netsh-wlan
REM 2: https://www.tenforums.com/tutorials/3562-add-remove-wireless-network-filter-windows-10-a.html
REM Objetivo: Bloqueia a possibilidade de conectar em qualquer WI-FI que não seja SEDUC-MAQ
netsh wlan add filter permission=allow ssid="SEDUC-MAQ" networktype=infrastructure
netsh wlan add filter permission=denyall networktype=infrastructure
netsh wlan set blockednetworks display=hide networktype=infrastructure


REM Fontes:
REM 1. https://www.elevenforum.com/t/change-lid-close-action-in-windows-11.3356/
REM 2. https://learn.microsoft.com/es-es/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action 
REM Obejtivo: Desligar notebook quando ele estiver fechado.
REM Lid = Tapa do notebook

REM Esquemas de Energia Existentes (* Ativos)
REM GUID do Esquema de Energia: 381b4222-f694-41f0-9685-ff5bb260df2e  (Equilibrado) *
REM GUID do Esquema de Energia: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (Alto desempenho)
REM GUID do Esquema de Energia: a1841308-3541-4fab-bc81-f71556f20b4a  (Economia de energia)

powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e sub_buttons LIDACTION 3
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e sub_buttons LIDACTION 3
powercfg -setActive 381b4222-f694-41f0-9685-ff5bb260df2e

powercfg -setacvalueindex a1841308-3541-4fab-bc81-f71556f20b4a sub_buttons LIDACTION 3
powercfg -setdcvalueindex a1841308-3541-4fab-bc81-f71556f20b4a sub_buttons LIDACTION 3
powercfg -setActive 381b4222-f694-41f0-9685-ff5bb260df2e

powercfg -setdcvalueindex SCHEME_CURRENT 381b4222-f694-41f0-9685-ff5bb260df2e 833a6b62-dfa4-46d1-82f8-e09e34d029d6 1
powercfg -setdcvalueindex SCHEME_CURRENT a1841308-3541-4fab-bc81-f71556f20b4a 833a6b62-dfa4-46d1-82f8-e09e34d029d6 1

REM Fontes: 
REM 1. https://superuser.com/questions/1619455/how-to-enable-disable-battery-saver-with-powershell
REM 2. https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/energy-saver-settings
REM Objetivo: Ativar economia de energia em X porcentagem.
REM No caso, 30%.
powercfg /setdcvalueindex a1841308-3541-4fab-bc81-f71556f20b4a SUB_ENERGYSAVER ESBATTTHRESHOLD 30
powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e SUB_ENERGYSAVER ESBATTTHRESHOLD 30


REM Objetivo: Remove opção de alto desempenho.
powercfg /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 

REM Fonte: 
REM 1. Gerado por Gemini.
REM 2. Política criada e testada por Pallas da Silva Guedes.
REM Objetivo: Adiconar Política de Grupo Personalizada ao Sistema.
REM Política: Bloquear qualquer executável de ser executado em usuários não administradores
powershell -Command "Import-Module AppLocker; Set-AppLockerPolicy -XmlPolicy 'C:\Proati-Scripts\Positivo-Sala-Aula\politicas\banir-executaveis.xml'"
sc config AppIDSvc start= auto
sc start AppIDSvc


REM Fontes:
REM 1. https://www.elevenforum.com/t/enable-or-disable-onedrive-in-windows-11.2318/
REM Objetivo: Desativa OneDrive.
REM Impedir de criar tarefas de sicronização para cada usuário no sistema.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 00000001 /f

REM Fontes:
REM 1. https://www.reddit.com/r/sysadmin/comments/1qw3903/any_way_to_reduce_the_preparing_windows_time_on_a/
REM 2. https://www.reddit.com/r/sysadmin/comments/1inzwvn/how_do_i_stop_windows_11_from_asking_admin/
REM Objetivo: Acelerar tela de login. e Desativa Windows Hello.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 00000000 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Settings" /v AllowSignInOptions /t REG_DWORD /d 00000000 /f

REM Fontes:
REM 1. https://www.reddit.com/r/techsupport/comments/125qacg/setting_a_default_lock_screen_login_screen/
REM 2. https://www.elevenforum.com/t/enable-or-disable-acrylic-blur-effect-on-sign-in-screen-background-in-windows-11.1117/
REM Objetivo: Definir tela de bloqueio personalizada para auxiliar login, e desativar efeito de transparencia na tela de login.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "LockScreenImage" /t REG_SZ /d "C:\Proati-Scripts\Positivo-Sala-Aula\wallpaper\positivo-wallpaper.jpeg" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v "LockScreenImageStatus" /t REG_DWORD /d "00000001" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v "LockScreenImagePath" /t REG_SZ /d "C:\Proati-Scripts\Positivo-Sala-Aula\wallpaper\positivo-wallpaper.jpeg" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoChangingLockScreen" /t REG_DWORD /d "00000001" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v "LockScreenImageUrl" /t REG_SZ /d "C:\Proati-Scripts\Positivo-Sala-Aula\wallpaper\positivo-wallpaper.jpeg" /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackgroundOnLogon /t REG_DWORD /d 00000001 /f

REM Fontes:
REM 1. https://www.elevenforum.com/t/enable-or-disable-dont-display-last-signed-in-user-on-sign-in-screen-in-windows-11.17256/
REM Objetivo: Não mostrar lista de usuários recentes na tela de bloqueio.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DontDisplayLastUserName" /t REG_DWORD /d "00000001" /f

REM Fontes:
REM 1. https://www.elevenforum.com/t/enable-or-disable-widgets-on-lock-screen-in-windows-11.33140/
REM Objetivo: Desativar widgets na tela de bloqueio.
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen" /v "LockScreenWidgetsEnabled" /t REG_DWORD /d 00000000 /f

REM Fontes: 
REM 1. https://www.elevenforum.com/t/check-enable-or-disable-trim-support-for-ssd-drives-in-windows-11.43525/
REM Objetivo: Ativar suporte ao TRIM ao sistema.
fsutil behavior set disabledeletenotify 0​

REM Fontes:
REM 1. https://www.elevenforum.com/t/add-or-remove-recommended-section-on-start-menu-in-windows-11.21508/
REM 2. https://www.elevenforum.com/t/add-or-remove-all-apps-section-on-start-menu-in-windows-11.9293/
REM Objetivo: Remover seção de recomendados no menu inicial e seção de todos.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d 00000001
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start" /v "ShowAllAppsSection" /t REG_DWORD /d 00000000

REM Fontes:
REM 1. https://www.elevenforum.com/t/turn-on-or-off-autoendtasks-at-sign-out-restart-shut-down-in-windows-11.8283/
REM 2. https://www.reddit.com/r/sysadmin/comments/1p6bewi/autoendtasks_doesnt_work_any_more_in_windows_11/?show=original 
REM Objetivo: Excerrar qualquer programa ou serviços quando estiver desligando, reiniciado ou sign-out.
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "AutoEndTasks" /t REG_DWORD /d 00000001 /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d 2000 /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d 5000 /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "WaitToKillServiceTimeout" /t REG_SZ /d 5000 /f

shutdown -t 10 /r /c "Reiniciando para aplicar as alterações."
