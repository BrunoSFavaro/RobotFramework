*** Settings ***
Library    Telnet
Library    SSHLibrary
Library    String
Library    OperatingSystem
Library    Process

*** Keywords ***

Conectar Equipamento Yocto
    [Arguments]               ${IP_EQ}  ${USER_SSH}  ${PASS_SSH}  ${USUARIOCHM}  ${SENHACHM}
    Abrir SSH remoto          ${IP_EQ}  ${USER_SSH}  ${PASS_SSH}
    SSHLibrary.Write          telnet -d localhost
    Log  message=Abrindo conexão com ${IP_EQ}
    Log  message=Abrindo CHM não formatado
    SSHLibrary.Read Until         expected=Opcao:
    SSHLibrary.Write              2
    SSHLibrary.Read Until         expected=Opcao:
    SSHLibrary.Write              F
    Log  message=Aguardando alocação do terminal 
#    Set Timeout               30 seconds
    SSHLibrary.Read Until         expected=Terminal livre

    Log  message=Realizando autenticação
    SSHLibrary.Write              \t
#    Set Timeout               10 seconds
    SSHLibrary.Read Until         expected=USUARIO = 
    SSHLibrary.Write              text=${USUARIOCHM}\r${SENHACHM}\r
    SSHLibrary.Read Until         expected=<
    Log  message=Conexão realizada com sucesso

Fechar conexao telnet
    Telnet.Close Connection
    Log  message=Conexão fechada com sucesso

Abrir SSH remoto
    [Arguments]                   ${IP}  ${USER}  ${PASS}
    Log  message=Abrindo conexão SSH com ${IP}
    SSHLibrary.Open Connection    ${IP}  term_type=ansi  prompt=$
    SSHLibrary.Login              ${USER}  ${PASS}

    Log  message=Padronizando o terminal
    SSHLibrary.Write              ~/robot_bash.sh
    SSHLibrary.Read Until Prompt

    Set Client Configuration      timeout=40s
    Log  message=Conexão realizada com sucesso

Fechar SSH remoto
    SSHLibrary.Close Connection
    Log  message=Conexão fechada com sucesso

Persistir shell
    Start Command    /bin/bash
    Log  message=Persistindo o shell

Mudar de diretorio
    [Arguments]                      ${DIR}
    SSHLibrary.Write     cd ${DIR}
    ${output}  SSHLibrary.Read Until Prompt
    Log  message=Diretório alterado para ${DIR}
    Log  ${output}                                      

Preparar ambiente basico
    [Arguments]          ${IP}  ${USER}  ${PASS}  ${DIR}
    Abrir SSH remoto     ${IP}  ${USER}  ${PASS}
    Mudar de diretorio   ${DIR}

Terminar ambiente
    Limpar ambiente
    Fechar SSH remoto

Executar cenario A
    [Arguments]                      ${CENARIO}  ${IP}  ${DEST}  ${ARQ}  ${QUANT}  ${DUR}=3000  #${TIPO}  
    SSHLibrary.Write                 ./runner.sh ${CENARIO} ${IP} ${DEST} ${ARQ} ${QUANT} ${DUR}
    ${output}  SSHLibrary.Read Until Prompt
    Log                              ${output}

Executar cenario B
    [Arguments]                      ${CENARIO}  ${IP}  ${ARQ}  ${QUANT}=1 
    SSHLibrary.Write                 ./sipp -sf ${CENARIO} -i ${IP} -inf ${ARQ} -aa -bg -trace_err -trace_msg -trace_logs -m ${QUANT} | grep -oP "PID=\[[0-9]+\]" | grep -oP "[0-9]+" > uas.pid
    ${output}  SSHLibrary.Read Until Prompt
    Log                              ${output}
 
Executar chamada
    [Arguments]                     ${CENARIO_B}  ${IP_B}  ${CENARIO_A}  ${IP_A}  ${DEST}  ${ARQ}  ${TIPO}  ${QUANT_A}=1  ${QUANT_B}=1  ${DUR}=3000  ${RES}=0  ${CSCSF}=ericsson
    SSHLibrary.Write                (echo "SEQUENTIAL"; grep ${TIPO} ${ARQ}) > tmp.csv
    Executar cenario B              ${CENARIO_B}  ${IP_B}  tmp.csv  ${QUANT_B}
    Executar cenario A              ${CENARIO_A}  ${IP_A}  ${DEST}  tmp.csv  ${QUANT_A}  ${TIPO}  ${DUR}  
    Conferir resultado              ${RES}

Conferir resultado
    [Arguments]    ${RES}
    SSHLibrary.Write    echo $?
    ${output}=    SSHLibrary.Read Until Prompt
    ${output}=    Strip String    ${output}
    @{lines}=    Split To Lines    ${output}
    ${rc}=    Set Variable    ${lines}[0]
    ${rc}=    Replace String    ${rc}  \n  ${EMPTY}
    ${rc}=    Replace String    ${rc}  \r  ${EMPTY}
    ${rc}=    Strip String      ${rc}
    Log    RC encontrado: |${rc}|
    Should Be Equal As Strings    ${RES}    ${rc}

Limpar ambiente
    SSHLibrary.Write    kill -9 $(cat uas.pid)
    ${output}=    SSHLibrary.Read Until Prompt
    Log    ${output}
    SSHLibrary.Write    rm -f uas.pid
    SSHLibrary.Read Until Prompt

Configuracao CTPE
    [Arguments]    ${NTL}  ${TBR}  ${FAR}  ${RCC}  ${CRE}
    SSHLibrary.Write Bare                      CNTLDS:ISV=cct_ctpe,NTL="${NTL}",TBR=${TBR},FAR=${FAR},RCC=${RCC},CRE=${CRE};
    SSHLibrary.Read Until Regexp               regexp=(NTL = ${NTL}|NUMERO NAO ASSOCIADO)
    SSHLibrary.Read Until                      expected=<
    SSHLibrary.Write Bare                      INTLDS:ISV=cct_ctpe,PDI="${NTL}";
    SSHLibrary.Read Until                      expected=NTL = ${NTL}
    SSHLibrary.Read Until                      expected=<

Desprogramar servico 1
    [Arguments]    ${ISV}  ${NTL}
    SSHLibrary.Write Bare                      SNTLDS:ISV=${ISV},NTL="${NTL}";
    SSHLibrary.Read Until Regexp               regexp=(NTL = 1134500000|NUMERO NAO ASSOCIADO)