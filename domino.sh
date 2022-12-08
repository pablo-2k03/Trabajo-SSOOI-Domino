#!/bin/bash
function menu(){
while [[ "$OPCION" != "S" ]] && [[ "$OPCION" != "s" ]]
do
  clear
  echo "=========================="
  echo -e "\tDomino"
  echo "=========================="
  echo "M) MODIFICAR CONFIGURACION"
  echo "J) JUGAR"
  echo "F) CLASIFICACION"
  echo "E) ESTADISTICAS"
  echo "S) SALIR"
  echo -e "'Domino'. Elija una opcion >> \c "
  read OPCION
  case $OPCION in
  "M" | "m")
    modificar
  ;;
  "J" | "j")
    rondas=1
    Puntos1=0
    Puntos2=0
    Puntos3=0
    Puntos4=0
    log_creado=0
    total_1=0
    total_2=0
    total_3=0
    total_4=0
    total=0
    jugar
  ;;
  "F" | "f")
    clasificacion
  ;;
  "E" | "e")
    estadisticas
  ;;
  "S" | "s")
  ;;
  esac
done
} #Linea 31
function modificar(){
#Obtenemos el numero de jugadores de la partida (info introducida por el usuario).
 file="config.cfg"
 while [[ "$OPCION" != "S" ]] && [[ "$OPCION" != "s" ]]
 do
  clear
  echo "=============================="
  echo -e "\tConfiguracion"
  echo "=============================="
  echo -e "\n Que opcion desea modificar? \n\ta)Numero de jugadores.\n\tb)Numero de puntos.\n\tc)Parametro inteligencia.\n\td)Ruta del fichero log.\n\tq)Salir.\n\n Elija una opcion >> \c "

  read OPCION
  case $OPCION in
  "a" | "A")
     JUGADORES=-1
     while [[("$JUGADORES" -lt 2) || ("$JUGADORES" -gt 4)]]
        do
        echo "Introduzca el numero de jugadores (comprendido entre 2 y 4)"
        read JUGADORES
        done
        sleep 1
        echo -e "\nModificando datos..."
        perl -pi -e 's/JUGADORES=.*/JUGADORES='$JUGADORES'/' $file
        sleep 1
                perl -pi -e 's/JUGADORES=.*/JUGADORES='$JUGADORES'/' $file
        sleep 1
                 echo "Numero de jugadores modificado correctamente."
        sleep 1
        ;;
  "b" | "B")
     PUNTOS=49
     #Obtenemos los puntos necesarios para ganar la partida (info introducida por el usuario).
      while [[("$PUNTOS" -lt 50) || ("$PUNTOS" -gt 100)]]
        do
        echo "Introduzca el numero de puntos que debe alcanzar un jugador para ganar la partida (comprendido entre 50 y 100)"
        read PUNTOS
        done
        sleep 1
        echo -e "\nModificando datos..."
        perl -pi -e 's/PUNTOSGANADOR=.*/PUNTOSGANADOR='$PUNTOS'/' $file
        sleep 1
        echo "Numero de puntos necesarios para ganar modificado correctamente."
        sleep 1
        ;;
  "C" | "c")
     #Obtenemos el valor booleano INTELIGENCIA.
        INTELIGENCIA=-1
        while [[("$INTELIGENCIA" -lt 0) || ("$INTELIGENCIA" -gt 1)]]
        do
        echo "Introduzca el parametro inteligencia (0 si quiere que los jugadores no interactivos intervengan de forma aleatoria o 1 si quiere que intervengan de forma sofisticada)"
        read INTELIGENCIA
        done
        sleep 1
        echo -e "\nModificando datos..."
        perl -pi -e 's/INTELIGENCIA=.*/INTELIGENCIA='$INTELIGENCIA'/' $file
        sleep 1

        echo "Parametro inteligencia modificado correctamente."
        sleep 1
        ;;
  "d" | "D")
     #Obtenemos la direccion donde quiere guardar el log
        LOG_FILE="fichero.log"
        echo "Introduzca la ruta donde desee guardar el log de la partida"
        read RUTA
        #Obtenemos el nombre del directorio que nos ha introducido el usuario.
        result=$(dirname "$RUTA")
        mkdir -p $result
        if test $? -eq 0
        #Creamos el fichero introducido en la variable RUTA)
        then
                        touch $RUTA
                        if test $? -eq 0
                        then
                                perl -pi -e 's|LOG=.*|LOG='$RUTA'|' $file
                                echo "Fichero ${RUTA##*/} creado correctamente en el directorio $result"
                                sleep 2
                        else
                                echo "ERROR. La ruta existe pero no se ha podido crear el fichero ${RUTA##*/} porque no se tienen permisos suficientes."
                                return 1
                        fi
        else
                        echo "ERROR. No se puede crear el directorio necesario para guardar el archivo log, asegurese de que la ruta existe y de ser asi, asegurese de tener los permisos necesarios."
                        sleep 2
                        return 1
        fi
                ;;
  "Q" | "q")
        echo -e "\nPulse INTRO para continuar"
        read espacio
        return;
        ;;
  esac
done
}
function ficha_mas_alta(){
 #Comprobaciones de quien empieza el juego.
 flag=1
 je=0
 for ((i=6;i>=0;i--));do
   for((j=6;j>=i;j--));do
     if [[ "${arrayfj1[@]}" =~ "$i:$j" ]]
        then
        je=1
        fichaAlta="[$i:$j]"
        for ((k=0;k<7;k++));do
                if [[ ${arrayfj1[$k]} == "[$i:$j]" ]]
                then
                                        pos=$k
                                        return
                fi
        done
     elif [[ "${arrayfj2[@]}" =~ "$i:$j" ]]
        then
                je=2
        fichaAlta="[$i:$j]"
        for ((k=0;k<7;k++));do
                if [[ ${arrayfj2[$k]} == "[$i:$j]" ]]
                then
                                        pos=$k
                                        return
                fi
        done
     elif [[ "${arrayfj3[@]}" =~ "$i:$j" ]] && [ $JUGADORES -ge 3 ]
        then
        je=3
        fichaAlta="[$i:$j]"
        for ((k=0;k<7;k++));do
                if [[ ${arrayfj3[$k]} == "[$i:$j]" ]]
                then
                                        pos=$k
                                        return
                fi
        done
     elif [[ "${arrayfj4[@]}" =~ "$i:$j" ]] && [ $JUGADORES -eq 4 ]
        then
        je=4
        fichaAlta="[$i:$j]"
        for ((k=0;k<7;k++));do
                if [[ ${arrayfj4[$k]} == "[$i:$j]" ]]
                then
                                        pos=$k
                                        return
                fi
        done
     fi
   done
 done
}
function mostrarMasAlta(){
if [[ $je -eq 1 ]]
 then
        echo "El jugador 1 empieza porque tiene la ficha mas alta"
        arrayfj1=(${arrayfj1[@]})
        unset 'arrayfj1[$pos]'
        arrayfj1=(${arrayfj1[@]})
        arrayfenjuego+=($fichaAlta)
        t1=1
        sleep 1
        c_Turno
 elif [[ $je -eq 2 ]]
        then
        echo "El jugador 2 empieza porque tiene la ficha mas alta"
        arrayfj2=(${arrayfj2[@]})
        unset 'arrayfj2[$pos]'
        arrayfj2=(${arrayfj2[@]})
        arrayfenjuego+=($fichaAlta)
        t2=1
        sleep 1
        c_Turno
 elif [[ $je -eq 3 ]] && [ $JUGADORES -ge 3 ]
        then
        echo "El jugador 3 empieza porque tiene la ficha mas alta"
        arrayfj3=(${arrayfj3[@]})
        unset 'arrayfj3[$pos]'
        arrayfj3=(${arrayfj3[@]})
        arrayfenjuego+=($fichaAlta)
        t3=1
        sleep 1
        c_Turno
 else
        echo "El jugador 4 empieza porque tiene la ficha mas alta"
        arrayfj4=(${arrayfj4[@]})
        unset 'arrayfj4[$pos]'
        arrayfj4=(${arrayfj4[@]})
        arrayfenjuego+=($fichaAlta)
        t4=1
        sleep 1
        c_Turno
 fi
}
t1=0
t2=0
t3=0
t4=0
function c_Turno(){
 source config.cfg
 JUGADORES="$JUGADORES"
 case "$JUGADORES" in
 "2")
 if [[ $t1 -eq 1 ]];then
        t1=0
        t2=1
 else
        t2=0
        t1=1

 fi
 ;;
 "3")
 if [[ $t1 -eq 1 ]];then
        t1=0
        t3=1
 elif [[ $t2 -eq 1 ]];then
        t2=0
        t1=1
 else
        t3=0
        t2=1

 fi
 ;;
 "4")
 if [[ $t1 -eq 1 ]];then
        t1=0
        t4=1
 elif [[ $t2 -eq 1 ]];then
        t2=0
        t1=1
 elif [[ $t3 -eq 1 ]];then
        t3=0
        t2=1
 else
        t4=0
        t3=1

 fi
 ;;
 esac
}
function reparto_fichas(){
 source config.cfg
 JUGADORES="$JUGADORES"
 fichas=("$@")
 arrayfj1=()
 arrayfj2=()
 if [[ $JUGADORES -eq 2 ]]
 then
 for i in {1..7};do
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj1+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj2+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
 done
 echo "Fichas Iniciales del Jugador 1: ${arrayfj1[@]}"
 echo "Fichas Iniciales del Jugador 2: ${arrayfj2[@]}"
 echo "POZO: ${#fichas[@]}"
 elif [[ $JUGADORES -eq 3 ]]
 then
 arrayfj3=()
 for i in {1..7};do
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj1+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj2+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj3+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
 done
 echo "Fichas Iniciales del Jugador 1: ${arrayfj1[@]}"
 echo "Fichas Iniciales del Jugador 2: ${arrayfj2[@]}"
 echo "Fichas Iniciales del Jugador 3: ${arrayfj3[@]}"
 echo "POZO: ${#fichas[@]}"
 else
 arrayfj4=()
 for i in {1..7};do
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj1+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj2+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj3+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
  fichas=(${fichas[@]})
  r_i=$(echo $[ $RANDOM % ${#fichas[@]} ])
  arrayfj4+=(${fichas[$r_i]})
  unset 'fichas[$r_i]'
 done
 echo "Fichas Iniciales del Jugador 1: ${arrayfj1[@]}"
 echo "Fichas Iniciales del Jugador 2: ${arrayfj2[@]}"
 echo "Fichas Iniciales del Jugador 3: ${arrayfj3[@]}"
 echo "Fichas Iniciales del Jugador 4: ${arrayfj4[@]}"
 echo "POZO: ${#fichas[@]}"
 fi
}
function robar(){
 if [[ ${#fichas[@]} -eq 0 ]]
 then
        echo "No se puede robar, no hay fichas en el pozo."
        return
 fi
 if [[ $t1 -eq 1 ]] && [[ ${#fichas[@]} -ne 0 ]]
 then
        i_r=$(echo $[ $RANDOM % ${#fichas[@]} ])
        arraygenerico+=(${fichas[$i_r]})
        unset 'fichas[$i_r]'
        fichas=(${fichas[@]})
        return
 elif [[ $t2 -eq 1 ]] && [[ ${#fichas[@]} -ne 0 ]]
  then
        i_r=$(echo $[ $RANDOM % ${#fichas[@]} ])
        arraygenerico+=(${fichas[$i_r]})
        unset 'fichas[$i_r]'
        fichas=(${fichas[@]})
        return
 elif [[ $t3 -eq 1 ]] && [[ ${#fichas[@]} -ne 0 ]]
 then
        i_r=$(echo $[ $RANDOM % ${#fichas[@]} ])
        arraygenerico+=(${fichas[$i_r]})
        unset 'fichas[$i_r]'
        fichas=(${fichas[@]})
        return
 else
        i_r=$(echo $[ $RANDOM % ${#fichas[@]} ])
        arraygenerico+=(${fichas[$i_r]})
        unset 'fichas[$i_r]'
        fichas=(${fichas[@]})
        return
 fi
}
function sumar_Fichas(){
 if [[ ${#arrayfj1[@]} -ne 0 ]] && [[ $gana -ne 1 ]]
 then
        for ((i=0;i<${#arrayfj1[@]};i++));do
                ni1=${arrayfj1[$i]:1:1}
                nd1=${arrayfj1[$i]:3:1}
                ((total_1+=$ni1+$nd1))
        done
        Puntos1=$total_1
 fi
 if [[ ${#arrayfj2[@]} -ne 0 ]] && [[ $gana -ne 2 ]]
 then
        for ((i=0;i<${#arrayfj2[@]};i++));do
                ni2=${arrayfj2[$i]:1:1}
                nd2=${arrayfj2[$i]:3:1}
                ((total_2+=$ni2+$nd2))
        done
 Puntos2=$total_2
 fi
 if [[ ${#arrayfj3[@]} -ne 0 ]] && [[ $gana -ne 3 ]]
 then
        for ((i=0;i<${#arrayfj3[@]};i++));do
                ni3=${arrayfj3[$i]:1:1}
                nd3=${arrayfj3[$i]:3:1}
                ((total_3+=$ni3+$nd3))
        done
 Puntos3=$total_3
 fi
 if [[ ${#arrayfj4[@]} -ne 0 ]] && [[ $gana -ne 4 ]]
 then
        for ((i=0;i<${#arrayfj4[@]};i++));do
                ni4=${arrayfj4[$i]:1:1}
                nd4=${arrayfj4[$i]:3:1}
        ((total_4+=$ni4+$nd4))
        done
 Puntos4=$total_4
 fi
 ((total+=$total_1+$total_2+$total_3+$total_4))
 if [[ $gana -eq 1 ]]
 then
        Puntos1=$total
        return
 fi
 if [[ $gana -eq 2 ]]
 then
        Puntos2=$total
        return
 fi
 if [[ $gana -eq 3 ]]
 then
        Puntos3=$total
        return
 fi
 if [[ $gana -eq 4 ]]
 then
        Puntos4=$total
        return
 fi
}
function sort_array(){
        IFS=$'\n'
        sorted=($(sort <<<"${arraygenerico[*]}"));
        unset IFS
        arraygenerico=("${sorted[@]}")
}
function vuelta(){
        x_i=${arraygenerico[$1]:3:1}
        i_x=${arraygenerico[$1]:1:1}
        estaGirada=1
        FichaVuelta="[$x_i:$i_x]"
}
function insertar_i(){
         if [[ $estaGirada -eq 1 ]]
         then
                arrayfenjuego=($FichaVuelta ${arrayfenjuego[@]})
         else
                arrayfenjuego=($FichaSinGirar ${arrayfenjuego[@]})
         fi
}
function insertar_d(){
        if [[ $estaGirada -eq 1 ]]
         then
                arrayfenjuego+=($FichaVuelta)
         else
                arrayfenjuego+=($FichaSinGirar)
         fi
}
function mostrarMenu(){
        clear
        echo "=============================="
        echo -e "\tMesa"
        echo "=============================="
        echo -e "\n"
        echo "En juego: ${arrayfenjuego[@]}"
        echo -e "\n"
        echo -e "Fichas en el pozo: ${#fichas[@]}"
        if [[ $JUGADORES -eq 2 ]]
        then
                echo "Fichas Jugador 1 ${arrayfj1[@]}"
                echo "Fichas Jugador 2 ${arrayfj2[@]}"
                                 elif [[ $JUGADORES -eq 3 ]]
        then
                echo "Fichas Jugador 1 ${arrayfj1[@]}"
                echo "Fichas Jugador 2 ${arrayfj2[@]}"
                echo "Fichas Jugador 3 ${arrayfj3[@]}"
        else
                echo "Fichas Jugador 1 ${arrayfj1[@]}"
                echo "Fichas Jugador 2 ${arrayfj2[@]}"
                echo "Fichas Jugador 3 ${arrayfj3[@]}"
                echo "Fichas Jugador 4 ${arrayfj4[@]}"
        fi
        echo -e "\n\n"
        if [[ $t1 -eq 1 ]]
        then
        echo "Turno del jugador 1"
        fi
        if [[ $t2 -eq 1 ]]
        then
        echo "Turno del jugador 2"
        fi
        if [[ $t3 -eq 1 ]]
        then
        echo "Turno del jugador 3"
        fi
        if [[ $t4 -eq 1 ]]
        then
        echo "Turno del jugador 4"
        fi

}
function eliminar_i(){
        unset 'arraygenerico[$1]'
        arraygenerico=(${arraygenerico[@]})
}
function busqueda_mayor(){

        mayor=${arraygenerico[0]}
        for((x=0;x<${#arraygenerico[@]};x++));do
                if [[ ${arraygenerico[$x]} > $mayor ]]
                then
                        pos=$x
                        mayor=${arraygenerico[$x]}
                fi
        done
}
function jugar_ordenador(){
    mostrarMenu
    flagi_i=0
    flagi_d=0
    flagd_i=0
    flagd_d=0
        if [[ ${#arraygenerico[@]} -ne 0 ]]
        then
        for ((i=0;i<${#arrayfenjuego[@]};i++))
        do
                m_i="${arrayfenjuego[0]:1:1}"
                m_d="${arrayfenjuego[-1]:3:1}"
                for ((j=${#arraygenerico[@]}-1; j>=0;j--))
                do
                        n_i="${arraygenerico[$j]:1:1}"
                        n_d="${arraygenerico[$j]:3:1}"
                        if [[ $n_i -eq $m_i ]]
                        then
                                flagi_i=1

                        elif [[ $n_d -eq $m_i ]]
                        then
                                flagi_d=1

                        elif [[ $n_i -eq $m_d ]]
                        then
                                flagd_i=1

                        elif [[ $n_d -eq $m_d ]]
                        then
                                flagd_d=1
                        fi
                        if test $flagi_i -eq 1
                        then
                                FichaSinGirar=("${arraygenerico[$j]}")
                                vuelta "$j"
                                insertar_i "$FichaVuelta"
                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                        if [[ ${arraygenerico[$k]} = "$FichaSinGirar" ]]
                                        then
                                                pos_f=$k
                                                break
                                        fi
                                done
                                eliminar_i "$pos_f"
                                return

                        fi
                        if test $flagi_d -eq 1
                                then
                                estaGirada=0
                                FichaSinGirar=("${arraygenerico[$j]}")
                                insertar_i "$FichaSinGirar"
                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                        if [[ ${arraygenerico[$k]} = "$FichaSinGirar" ]]
                                        then
                                                pos_f=$k
                                                break
                                        fi
                                done
                                eliminar_i "$pos_f"
                                return


                        fi
                        if test $flagd_i -eq 1
                        then
                                estaGirada=0
                                FichaSinGirar=("${arraygenerico[$j]}")
                                insertar_d "$FichaSinGirar"
                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                        if [[ ${arraygenerico[$k]} = "$FichaSinGirar" ]]
                                        then
                                                pos_f=$k
                                                break
                                        fi
                                done
                                eliminar_i "$pos_f"
                                return

                        fi
                        if test $flagd_d -eq 1
                        then
                                estaGirada=0
                                FichaSinGirar=("${arraygenerico[$j]}")
                                vuelta "$j"
                                insertar_d "$FichaVuelta"
                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                        if [[ ${arraygenerico[$k]} = "$FichaSinGirar" ]]
                                        then
                                                pos_f=$k
                                                break
                                        fi
                                done
                                eliminar_i "$pos_f"
                                return

                        fi
                done
                if test ${#fichas[@]} -ne 0
                        then
                             robar "${arraygenerico[@]}"
                                return
                        else
                                break
                fi
        done
        else
                echo "Ha ganado la partida con $total puntos"
                return

        fi
}
function eleccion_Ficha(){
 flagi_i=0
 flagi_d=0
 flagd_i=0
 flagd_d=0
 if [[ ${#arraygenerico[@]} -eq 0 ]]
 then
 sumar_Fichas
 echo "El jugador domino la partida con $total puntos"
 return
 else
 if [[ ${#arrayfenjuego[@]} -ne 0 ]]
 then
        echo "Introduzca la ficha que desee añadir a la mes: [x:y] "
        read FICHA
        nij=${FICHA:1:1}
        ndj=${FICHA:3:1}
        for ((i=0;i<${#arrayfenjuego[@]};i++));do
        if [[ $i -eq 0 ]]
                 then
                n_i="${arrayfenjuego[$i]:1:1}"
        fi
        if [[ $i -eq ${#arrayfenjuego[@]}-1 ]]
        then
                 n_d="${arrayfenjuego[$i]:3:1}"
        fi
        done
        for((i=0;i<${#arraygenerico[@]};i++));do
                if [[ $nij -eq $n_i ]]
                then
                        flagi_i=1
                fi
                if [[ $nij -eq $n_d ]]
                then
                        flagd_i=1
                fi
                if [[ $ndj -eq $n_i ]]
                then
                        flagi_d=1
                fi
                if [[ $ndj -eq $n_d ]]
                then
                         flagd_d=1
                fi
        done
 if [[ $flagi_i -eq 1 ]] || [[ $flagi_d -eq 1 ]] || [[ $flagd_i -eq 1 ]] || [[ $flagd_d -eq 1 ]]
 then
        found=0
        while :;do
        echo -e "Donde quieres insertar la ficha?.\n1)Derecha.\n2)Izquierda.\nElije ==> \c"
        read OPTFICHA
        case $OPTFICHA in
        "1")
                for ((i=0;i<${#arrayfenjuego[@]};i++));do
                                        m_i="${arrayfenjuego[$i]:1:1}"
                                        m_d="${arrayfenjuego[$i]:3:1}"
                                        for ((j=0; j<${#arraygenerico[@]};j++));do
                                                n_i="${arraygenerico[$j]:1:1}"
                                                n_d="${arraygenerico[$j]:3:1}"
                                                if [[ $flagd_d -eq 1 ]]
                                                then
                                                        nni2=${FICHA:1:1}
                                                        nnd2=${FICHA:3:1}
                                                        if [[ "${arraygenerico[@]}" =~ $FICHA ]]
                                                        then
                                                                k=0
                                                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                                                        if [[ "${arraygenerico[$k]}" == "$FICHA" ]]
                                                                        then
                                                                                pos=$k
                                                                                break;
                                                                        fi
                                                                done
                                                                estaGirada=0
                                                                FichaSinGirar=$FICHA
                                                                vuelta "$k"
                                                                insertar_d
                                                                eliminar_i "$k"
                                                                flagd_d=0
                                                                return
                                                        else
                                                                echo "La ficha introducida no se encuentra en el array, por favor, introduzca una valida."
                                                                return
                                                        fi
                                                fi
                                                if [[ $flagd_i -eq 1 ]]
                                                then
                                                        nni2=${FICHA:1:1}
                                                        nnd2=${FICHA:3:1}
                                                        if [[ "${arraygenerico[@]}" =~ $FICHA ]]
                                                        then
                                                                nni2=${FICHA:0:1}
                                                                nnd2=${FICHA:2:1}
                                                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                                                        if [[ ${arraygenerico[$k]} == "$FICHA" ]]
                                                                                then
                                                                                        pos=$k
                                                                                        break;
                                                                                fi
                                                                done
                                                                estaGirada=0
                                                                FichaSinGirar=$FICHA
                                                                insertar_d "$FICHA"
                                                                eli=$pos
                                                                eliminar_i "$k"
                                                                flagd_i=0
                                                                return
                                                        else
                                                                echo "La ficha introducida no se encuentra en el array, por favor, introduzca una valida."
                                                                return
                                                        fi
                                                fi
                                        done
                                done
        ;;
        "2")
             for((i=0;i<${#arrayfenjuego[@]};i++));do
                                        m_i="${arrayfenjuego[$i]:1:1}"
                                        m_d="${arrayfenjuego[$i]:3:1}"
                                        for ((j=0; j<${#arraygenerico[@]};j++));do
                                                n_i="${arraygenerico[$j]:1:1}"
                                                n_d="${arraygenerico[$j]:3:1}"
                                                if [[ $flagi_i -eq 1 ]]
                                                then
                                                        nni2=${FICHA:1:1}
                                                        nnd2=${FICHA:3:1}
                                                        if [[ "${arraygenerico[@]}" =~ $FICHA ]]
                                                        then
                                                                k=0
                                                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                                                        if [[ "${arraygenerico[$k]}" == "$FICHA" ]]
                                                                        then
                                                                                pos=$k
                                                                                break;
                                                                        fi
                                                                done
                                                                estaGirada=0
                                                                FichaSinGirar=$FICHA
                                                                vuelta "$k"
                                                                insertar_i "$FICHA"
                                                                eliminar_i "$k"
                                                                flagi_i=0
                                                                return
                                                        else
                                                                echo "La ficha introducida no se encuentra en el array, por favor, introduzca una valida."
                                                                return
                                                        fi
                                                fi
                                                if [[ $flagi_d -eq 1 ]]
                                                then
                                                        nni2=${FICHA:1:1}
                                                        nnd2=${FICHA:3:1}
                                                        if [[ "${arraygenerico[@]}" =~ $FICHA ]]
                                                        then
                                                                nni2=${FICHA:0:1}
                                                                nnd2=${FICHA:2:1}
                                                                for ((k=0;k<${#arraygenerico[@]};k++));do
                                                                        if [[ ${arraygenerico[$k]} == "$FICHA" ]]
                                                                                then
                                                                                        pos=$k
                                                                                        break;
                                                                                fi
                                                                done
                                                                estaGirada=0
                                                                FichaSinGirar=$FICHA
                                                                insertar_i "$FICHA"
                                                                eli=$pos
                                                                eliminar_i "$k"
                                                                flagi_d=0
                                                                return
                                                        else
                                                                echo "La ficha introducida no se encuentra en el array, por favor, introduzca una valida."
                                                                return
                                                        fi
                                                fi
                                        done
                                done
        ;;
        *)
                echo "Introduzca una opcion valida."
                                  ;;
        esac
        done
 else
 echo "No  se pueden poner fichas en el tablero."
 fi
 fi
 fi
 return
}
function crear_log_partida(){
   log_creado=1
   f_p=$(nawk "BEGIN {print srand}")
   f_p_h=$(date | cut -d "," -f 3|xargs| cut -d " " -f 1)
   TiempoPartida=$(expr $f_p - $h_i)
   puntoswinner=$(echo $Puntos1 $Puntos2 $Puntos3 $Puntos4 | tr " " "\n" |sort -n | tail -1)
   fecha=$(date | cut -d "," -f 2 | xargs)
   if [[ $Puntos1 -gt $Puntos2 ]] && [[ $Puntos1 -gt $Puntos3 ]] && [[ $Puntos1 -gt $Puntos4 ]]
   then
   ganador="Jugador 1"
   elif [[ $Puntos2 -gt $Puntos1 ]] && [[ $Puntos2 -gt $Puntos3 ]] && [[ $Puntos2 -gt $Puntos4 ]]
   then
        ganador="Jugador 2"
   elif [[ $Puntos3 -gt $Puntos1 ]] && [[ $Puntos3 -gt $Puntos2 ]] && [[ $Puntos3 -gt $Puntos4 ]]
   then
        ganador="Jugador 3"
   else
        ganador="Jugador 4"
   fi
   if [[ $JUGADORES -eq 2 ]]
   then
        Puntos3="*"
        Puntos4="*"
   fi
   if [[ $JUGADORES -eq 3 ]]
   then
        Puntos4="*"
   fi
   puntosjugadores=$(echo $Puntos1 $Puntos2 $Puntos3 $Puntos4 |tr " " "\n" | sort -nr |tr "\n" " " | tr " " "-")
   sleep 1
   echo "Volcando a fichero log..."
   sleep 1
   source config.cfg
   RUTA="$LOG"
   echo "$fecha|$f_p_h|$JUGADORES|$TiempoPartida|$rondas|$Inteligencia|$Puntos_Ganar|$ganador|${puntosjugadores::-1}" >> $RUTA
   sleep 1
   echo "Log de la partida guardado correctamente"
   echo "Pulsa INTRO para continuar"
   read INTRO
   arrayfenjuego=()
   return
}
function jugar_jugador1(){
         mostrarMenu
         while :;do
         echo -e "\nSeleccione una opcion\n=====================\na)ROBAR.\nb)PASAR.\nc)PONER."
         read PLAYER_OPTION
         case $PLAYER_OPTION in
                "a" | "A")
                robar "${arraygenerico[@]}"
                break
                ;;
                "b" | "B")
                break
                ;;
                "c" | "C")
                eleccion_Ficha
                break
                ;;
                "s" | "S")
                echo "Acabar Partida."
                ha_Roto=1
                return
                                ;;
                *)
                echo "Introduzca una opcion valida"
                ;;
        esac
        done
}
function jugar() {
 source config.cfg
 Jugadores="$JUGADORES"
 Puntos_Ganar="$PUNTOSGANADOR"
 Inteligencia="$INTELIGENCIA"
 RUTA="$LOG"
 fichero="config.cfg"
 #La expresion regular ^[0-9]+$ nos ayuda a comprobar si la informacion que tenemos almacenada en el fichero config.cfg es un valor valido o no.
 Int_ValidatorJ="^[0-4]+$"
 Int_ValidatorP="^[50-100]+$"
 Int_ValidatorI="^[0-1]+$"
 lineasf=$(wc -l $fichero | xargs| cut -d " " -f 1)
 if ! [[ $JUGADORES =~ $Int_ValidatorJ ]] || ! [[ $Puntos_Ganar =~ $Int_ValidatorP ]] || ! [[ $Inteligencia =~ $Int_ValidatorI ]] || [[ $lineasf -ne 4 ]]
  then echo "El archivo config.cfg tiene algun valor erroneo, por favor, revise la configuracion."
  sleep 2
  return 1
 fi
 fichas=("[0:0]" "[0:1]" "[0:2]" "[0:3]" "[0:4]" "[0:5]" "[0:6]" "[1:1]" "[1:2]" "[1:3]" "[1:4]" "[1:5]" "[1:6]" "[2:2]" "[2:3]" "[2:4]" "[2:5]" "[2:6]" "[3:3]" "[3:4]" "[3:5]" "[3:6]" "[4:4]" "[4:5]" "[4:6]" "[5:5]" "[5:6]"
"[6:6]")
   h_i=$(nawk "BEGIN{print srand}")
   t1=0
   finPartida=0
   t2=0
   t3=0
   t4=0
   log_creado=0
   arrayfj1=()
   arrayfj2=()
   arrayfj3=()
   arrayfj4=()
   arrayfenjuego=()
   reparto_fichas "${fichas[@]}"
   ficha_mas_alta
   mostrarMasAlta
   gana=0
   while [[ $Puntos1 -lt $Puntos_Ganar ]] || [[ $Puntos2 -lt $Puntos_Ganar ]] || [[ $Puntos3 -lt $Puntos_Ganar ]] || [[ $Puntos4 -lt $Puntos_Ganar ]];do
   if [[ $t2 -eq 1 ]] || [[ $t3 -eq 1 ]] || [[ $t4 -eq 1 ]]
   then
                if [[ $t2 -eq 1 ]]
                then
                        arraygenerico=("${arrayfj2[@]}")
                        PuntosGenericos=$Puntos2
                        if [[ $Inteligencia -eq 1 ]]
                        then
                                sort_array "${arraygenerico[@]}"
                                busqueda_mayor "${arraygenerico[@]}"
                        fi
                        jugar_ordenador
                        arrayfj2=("${arraygenerico[@]}")
                        if [[ ${#arrayfj2[@]} -eq 0 ]]
                        then
                                gana=2
                                sumar_Fichas "$Puntos2"
                                echo "El jugador 2 domino la ronda."
                                echo "Puntos j2 $Puntos2"
                                if [[ $Puntos2 -lt $Puntos_Ganar ]] && [[ $finPartida -eq 0 ]]
                                then
                                        rondas=$((rondas+1))
                                        jugar
                                        finPartida=1

                                        if [[ $log_creado -eq 0 ]]
                                        then
                                                crear_log_partida
                                                return
                                        fi

                                        break

                                fi
                                echo "El jugador 2 domino la partida."
                                finPartida=1
                                break
                        else
                                c_Turno
                        fi
                fi
                if [[ $t3 -eq 1 ]]
                then
                        arraygenerico=("${arrayfj3[@]}")
                        PuntosGenericos=$Puntos3
                        if [[ $Inteligencia -eq 1 ]]
                        then
                                sort_array "${arraygenerico[@]}"
                                busqueda_mayor "${arraygenerico[@]}"
                        fi
                        jugar_ordenador
                        arrayfj3=("${arraygenerico[@]}")
                        if [[ ${#arrayfj3[@]} -eq 0 ]]
                        then
                                gana=3
                                sumar_Fichas "$Puntos3"
                                echo "Puntos j3 $Puntos3"
                                echo "El jugador 3 domino la ronda."
                                if [[ $Puntos3 -lt $Puntos_Ganar ]] && [[ $finPartida -eq 0 ]]
                                then
                                        rondas=$((rondas+1))
                                        jugar
                                        if [[ $log_creado -eq 0 ]]
                                        then
                                                crear_log_partida
                                                return
                                        fi

                                        finPartida=1
                                        break

                                fi
                                echo "El jugador 3 domino la partida."
                                finPartida=1
                                break
                        else
                                c_Turno
                        fi
                fi
                if [[ $t4 -eq 1 ]]
                then
                        arraygenerico=("${arrayfj4[@]}")
                        PuntosGenericos=$Puntos4
                        if [[ $Inteligencia -eq 1 ]]
                        then
                                sort_array "${arraygenerico[@]}"
                                busqueda_mayor "${arraygenerico[@]}"
                        fi
                        jugar_ordenador
                        arrayfj4=("${arraygenerico[@]}")
                        if [[ ${#arrayfj4[@]} -eq 0 ]]
                        then
                                gana=4
                                sumar_Fichas "$Puntos4"
                                echo "Puntos j4 $Puntos4"
                                echo "El jugador 4 domino la ronda."
                                if [[ $Puntos4 -lt $Puntos_Ganar ]] && [[ $finPartida -eq 0 ]]
                                then

                                    rondas=$((rondas+1))
                                    jugar
                                    if [[ $log_creado -eq 0 ]]
                                        then
                                                crear_log_partida
                                                return
                                    fi
                                    break
                                fi
                                echo "El jugador 4 domino la partida."
                                finPartida=1
                                break
                        else
                                c_Turno
                        fi
                fi
        fi
        if [[ $t1 -eq 1 ]]
        then
                arraygenerico=("${arrayfj1[@]}")
                PuntosGenericos=$Puntos1
                jugar_jugador1
                arrayfj1=("${arraygenerico[@]}")
                if [[ ${#arrayfj1[@]} -eq 0 ]] || [[ $ha_Roto -eq 1 ]]
                then
                    gana=1
                    sumar_Fichas "$Puntos1"
                    echo "Puntos j1 $Puntos1"
                    echo "El jugador 1 domino la ronda."
                    if [[ $Puntos1 -lt $Puntos_Ganar ]] && [[ $finPartida -eq 0 ]]
                    then
                           rondas=$((rondas+1))
                           jugar
                           if [[ $log_creado -eq 0 ]]
                           then
                                        crear_log_partida
                                        return
                            fi
                           finPartida=1
                           break

                    fi
                    echo "El jugador 1 domino la partida."
                    finPartida=1
                    break
                else
                    c_Turno
                fi
        fi
   done
}
function estadisticas(){
        clear
        source config.cfg
        RUTA="$LOG"
        lineas=$(wc -l $RUTA 2>/dev/null | xargs | cut -d " " -f 1)
        if [[ $lineas -eq 0 ]]
        then
        echo "Error, el fichero esta vacio."
        return
        fi
        echo "========================================"
        echo "            ESTADISTICAS                "
        echo "========================================"
        media_ptos=$(expr $(cat $RUTA | cut -d "|" -f 9| cut -d "-" -f 1 | xargs | tr " " "+" | bc) / $lineas)
        media_rondas=$(expr $(cat $RUTA | cut -d "|" -f 5 | xargs | tr -d "r" | tr " " "+" | bc) / $lineas)
        media_tiempos=$(expr $(cat $RUTA | cut -d "|" -f 4 | xargs | tr -d "m" | tr " " "+" | bc) / $lineas)
        tiempo_total=$(expr $(cat $RUTA | cut -d "|" -f 4 | xargs | tr -d "m" | tr " " "+" | bc))
        porc_part_jug_intel=$(echo $(echo "scale=2;" $(cat $RUTA | cut -d "|" -f 6| xargs | tr " " "+" | bc)/$lineas | bc -l)*100 | bc)
        media_puntos_Totales=$(echo $(echo $(echo $(echo $(cat $RUTA | cut -d "|" -f 9| xargs| tr "-" "+" | tr " " "+" | bc)/$lineas) | bc)/4) | bc)
        echo "Numero de partidas jugadas: $lineas"
        echo "Media de puntos ganadores: $media_ptos"
        echo "Media de las rondas: $media_rondas"
        echo "Media de los tiempos: $media_tiempos"
        echo "Tiempo total invertido: $tiempo_total"
        echo "Porcentaje de partidas jugadas con inteligencia: $porc_part_jug_intel%"
        echo "Media de la suma de los puntos obtenidos por todos los jugadores: $media_puntos_Totales"
		echo -e "\n"
		echo "Pulse INTRO para continuar"
		read INTRO
}
function clasificacion(){
        clear
        source config.cfg
        RUTA="$LOG"
        lineas=$(wc -l $RUTA 2>/dev/null | xargs | cut -d " " -f 1)
        if [[ $lineas -eq 0 ]]
        then
        echo "Error, el fichero esta vacio."
        return
        fi
        echo "========================================"
        echo "            CLASIFICACION               "
        echo "========================================"
        part_mas_corta=$(grep $(cat $RUTA | cut -d "|" -f 4 | sort -n | head -n1) log | head -n1 $RUTA)
        part_mas_larga=$(grep $(cat $RUTA | cut -d "|" -f 4 | sort -n | tail -1) log | tail -1 $RUTA)
        part_mas_rondas=$(grep $(cat $RUTA | cut -d "|" -f 5 | sort -n | tail -1) log | tail -1 $RUTA)
        part_menos_rondas=$(grep $(cat $RUTA | cut -d "|" -f 5 | sort -n | head -n1) log | head -n1 $RUTA)
        part_mas_puntos_ganador=$(grep $(cat $RUTA | cut -d "|" -f 7 | sort -n | tail -1) log | tail -1 $RUTA)
        part_mas_puntos_obtenidos=$(grep $(cat $RUTA | cut -d "|" -f 9 | cut -d "-" -f 1  | sort -n | head -n1) log | tail -1 $RUTA)
        echo -e "Datos de la partida mas corta: \t\t\t$part_mas_corta"
        echo -e "Datos de la partida mas larga: \t\t\t$part_mas_larga"
        echo -e "Datos de la partida con mas rondas: \t\t$part_mas_rondas"
        echo -e "Datos de la partida con menos rondas: \t\t$part_menos_rondas"
        echo -e "Datos de la partida con mas puntos ganador: \t$part_mas_puntos_ganador"
        echo -e "Datos de la partida con mas puntos obtenidos: \t$part_mas_puntos_obtenidos"
		echo -e "\n"
		echo "Pulse INTRO para continuar"
		read INTRO
}
function presenta_autores(){
  echo "========================================"
  echo "                AUTORES"
  echo "========================================"
  echo "Trabajo realizado por:
  Pablo Aguera Hernandez  DNI: 70959394R
  Carlota Delgado Sastre  DNI: 70919297Q "
  echo "========================================"
  sleep 5
  clear
  menu
}

#Precondiciones iniciales, comprobacion de argumentos pasados y de existencia del fichero config.cfg
if test "$1" == "-g"
  then if test -f config.cfg
       then presenta_autores
       else
       echo "El fichero config.cfg es necesario para la utilizacion del programa"
       fi
elif test "$1" != "-g" && test "$#" -ne 0
  then echo "Usage: ./domino.sh [-g] Comment: The [] is optional."
elif test -f config.cfg
  then menu
else echo "El fichero config.cfg es necesario para la utilizacion del
programa"
fi
