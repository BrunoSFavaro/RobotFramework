*** Settings ***
Documentation    Essa suite é um projeto de automatizar testes para futuras mudanças envolvendo cenário AS-NGIN
Resource         resources.robot
Variables        local_env.py
#Test Setup       Preparar ambiente basico  ${SIPP}  ${USER_SIPP}  ${PASS_SIPP}  /home/robotfw/poc_ngin
#Test Teardown    Terminar ambiente

*** Variables ***



*** Test Cases ***

caso1_bloqueio_ctpe
    [Documentation]                      Teste ctpe
    [Tags]                               servicos       
    Conectar Equipamento Yocto           ${EQ}  matuser  matuser2  ${USER_EQ}  ${PASS_EQ}
    Configuracao CTPE                    1134500000  90  aplica  nao  1
 #   Abrir SSH remoto                     ${SIPP}  ${USER_SIPP}  ${PASS_SIPP}
 #   Executar cenario A                   uac_603.xml  ${IP_SIPP}  ${DEST}  db60.csv  1 
 #   Conferir resultado                   0
 #   Desprogramar serviços                1130002000    TNR
 #   Remover serviços                     1130002000    TNR
    Fechar SSH remoto