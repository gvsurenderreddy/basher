NO_COLOR="\[\e[0m\]"    # unsets color to term's fg color

# regular colors
K="\[\e[0;30m\]"    # black
R="\[\e[0;31m\]"    # red
G="\[\e[0;32m\]"    # green
Y="\[\e[0;33m\]"    # yellow
B="\[\e[0;34m\]"    # blue
M="\[\e[0;35m\]"    # magenta
C="\[\e[0;36m\]"    # cyan
W="\[\e[0;37m\]"    # white

# emphasized (bolded) colors
EMK="\[\e[1;30m\]"
EMR="\[\e[1;31m\]"
EMG="\[\e[1;32m\]"
EMY="\[\e[1;33m\]"
EMB="\[\e[1;34m\]"
EMM="\[\e[1;35m\]"
EMC="\[\e[1;36m\]"
EMW="\[\e[1;37m\]"

# background colors
BGK="\[\e[40m\]"
BGR="\[\e[41m\]"
BGG="\[\e[42m\]"
BGY="\[\e[43m\]"
BGB="\[\e[44m\]"
BGM="\[\e[45m\]"
BGC="\[\e[46m\]"
BGW="\[\e[47m\]"

HOSTNAME_SHORT=`hostname | cut -d'.' -f1 | tr "[:upper:]" "[:lower:]"`

serverrole(){
    # Is the role explicitly set in the system directory?
    if [ -f $ETC/server-role ] ; then
        SERVER_ROLE=$(<$ETC/server-role)
    # Is the role explicitly set in the home directory?
    elif [ -f ${HOME}/.server-role ] ; then
        SERVER_ROLE=$(<${HOME}/.server-role)
    # Should we set role based on host name?
    else
        case $HOSTNAME_SHORT in
            pcoslmu01|pcosldw01|pcoslds01|pcoslml01) SERVER_ROLE=production ;;
            usmule|usdoracle|usdatasniffer2|matlabwdc) SERVER_ROLE=tester ;;
            *) SERVER_ROLE=development ;;
        esac
    fi


    SERVER_ROLE=`echo $SERVER_ROLE | tr "[:upper:]" "[:lower:]"` # # lowercase the role
    case $SERVER_ROLE in
        prod*)
            ROLE_COLOR=$EMW$BGR
            SERVER_ROLE=`echo $SERVER_ROLE | tr "[:lower:]" "[:upper:]"` # Uppercase the role
        ;;
        lab|test*) ROLE_COLOR=$Y ;;
        *) ROLE_COLOR=$NO_COLOR ;;
    esac
    return 0
}

hostusercolor(){
    case $HOSTNAME_SHORT in
        pcoslmu01|usmule) HOST_COLOR=$EMG ;;
        pcosldw01|usdoracle) HOST_COLOR=$EMM ;;
        pcoslds01|usdatasniffer2) HOST_COLOR=$EMB ;;
        pcoslml01|matlabwdc) HOST_COLOR=$EMC ;;
        *) HOST_COLOR=$EMK ;;
    esac

    USER_COLOR=$HOST_COLOR

    if [ $UID -eq "0" ];
        then USER_COLOR=$R   # root's color
    fi
    return 0
}


function jobsrunning(){
    local numjobs
    numjobs=`jobs|\\grep -v autojump|wc -l|sed 's/ *//g'`
    if [[ ${numjobs} != '0' ]]; then
        echo "(${numjobs}) "
    fi

    return 0
}


colorprompt(){
    local EXITSTATUS=$?
    if [ "$EXITSTATUS" -eq "0" ];
    then
        if type __git_ps1 >/dev/null 2>&1; then
            PS1="${ROLE_COLOR}${SERVER_ROLE}${NO_COLOR} ${USER_COLOR}\u${HOST_COLOR}@\h:\w$(__git_ps1 " (%s)") `jobsrunning`\[\e[0;33m\][\!]${NO_COLOR}\$ " # yellow status
        else
            PS1="${ROLE_COLOR}${SERVER_ROLE}${NO_COLOR} ${USER_COLOR}\u${HOST_COLOR}@\h:\w `jobsrunning`\[\e[0;33m\][\!]${NO_COLOR}\$ " # yellow status
        fi
    else
        if type __git_ps1 >/dev/null 2>&1; then
            PS1="${ROLE_COLOR}${SERVER_ROLE}${NO_COLOR} ${USER_COLOR}\u${HOST_COLOR}@\h:\w$(__git_ps1 " (%s)") `jobsrunning`\[\e[1;31m\][\!]${NO_COLOR}\$ " # bold red status
        else
            PS1="${ROLE_COLOR}${SERVER_ROLE}${NO_COLOR} ${USER_COLOR}\u${HOST_COLOR}@\h:\w `jobsrunning`\[\e[1;31m\][\!]${NO_COLOR}\$ " # bold red status
        fi
    fi
}

'serverrole'
'hostusercolor'
PROMPT_COMMAND='colorprompt;history -a'

