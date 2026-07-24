*** Settings ***
Documentation    Essa suite é um projeto de automatizar testes para futuras mudanças envolvendo cenário AS-NGIN
Resource         resources.robot
#Test Setup       Preparar ambiente basico  ${SIPP}  ${USER_SIPP}  ${PASS_SIPP}  /home/robotfw/poc_ngin
#Test Teardown    Terminar ambiente

*** Variables ***



*** Test Cases ***

caso1_bloqueio_ctpe
    [Documentation]                      Teste ctpe
    [Tags]                               servicos       
    Conectar CHM                         ${EQ}  matuser  matuser2  ${USER_EQ}  ${PASS_EQ}
    Desprogramar servico 1               CCT_CTPE    1134500000
    Configuracao CTPE                    1134500000  90  aplica  nao  1
    Configuracao Apl Rota                CCT_CTPE    3   1
    Ativar Log do BI                    caabs  ${EQ}  ${USER_YOCTO}  ${PASS_YOCTO}  ${MPG}  ${PASS_MPG}  CONEXAO_MPG
    Disparar Chamadas SIPp               ${DEST}  ${IP_SIPP}  NUM_A=1134500000  NUM_B=F33314222
    Validar Log do BI
    Desprogramar servico 1               CCT_CTPE    1134500000
    Desconfiguracao Apl Rota             CCT_CTPE    3
    Fechar SSH remoto