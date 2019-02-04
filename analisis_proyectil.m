%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alvaro S. Fern‡ndez Malag—n
%Trabajo Fin de Master Ingenieria Industrial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Programa que permite analizar el daño generado por un proyectil en un cuerpo.
    
format long
clear all; clc; close all;

%Esto sirve para guardar el directorio inial y volver al finalizar el programa
diract = cd;

%Abrimos la carpeta que queramos en el cd, es decir, el directorio
%seleccionado si no elegimos ninguna devuelve 0
directori0 = uigetdir(cd,'Elige la carpeta de imagenes que desees cargar');

% si el directorio0 es igual 0 aparece el mensaje escrito a continuaci?n
if isequal(directori0,0)
    msgbox('No ha elegido ninguna carpeta','MENSAJE','help')
    return
end

%Obtener imagenes de la carpeta que queramos utilizar
cd(directori0)
lista = dir('*jpg');

%Obtenemos el numero de fotos que hay en la carpeta
[p,~] = size(lista);
if isequal(p,0)
    msgbox('No hay ninguna imagen en la carpeta especificada','MENSAJE','help')
    cd(diract)
    return
end

%Obtenemos el nombre de las fotos y los almacenamos en la matriz names
names = cell(p,1);
for i = 1:p
    names{i} = lista(i).name;
end

%Preguntamos el lado por donde entra la bala
lado = input('Cual es el lado por el que entra la bala en la gelatina? I(izquierda) o D (derecha):','s');

%Preguntamos la masa de la bala
masa = input('Masa de la bala (gr):');
%Pasamos la masa a kg
masa=masa/1000;

%Preguntamos el valor longitudinal de la gelatina balistica
longitud_gelatina_mm=input('Longitud real de la gelatina balistica (mm):');

%Frames por segundo
fps=input('Frames por segundo:');

%Cogemos la ultima imagen de la carpeta para cortarla y binarizarla
im_entrada = imread(names{end});

%Cortamos imagen y nos quedamos con lo que necesitamos
disp('Seleccione la fisura');
fis='S';
while fis=='S'
%selecciono la parte de la probeta a analizar y la guardo en 'a' para hacer lo mismo en todas las fotos   
[I1,a]=imcrop(im_entrada);
imshow(I1) %muestra la imagen cortada
fis=input('Quiere volver a elegir la fisura? (S/N):','s');
end

%Calculo dimensiones imagen
[m,n] = size (I1);

%Creo una imagen de salida con fondo blanco con las dimensiones de la imagen de entrada
im_salida = ones(m,n);

%Determinamos el umbral y cortamos utilizando una imagen intermedia 
lv='S';
while lv=='S'
T=input('Determine el valor del umbral para pasar a binario (valores recomendados entre 40-60):');
close all;
%Con estos dos bucles voy recorriendo la imagen de entrada pixel por pixel y si el pixel de la imagen de 
%entrada es mayor que el umbral T lo convierto en negro en la imagen de salida y si es menor que T en blanco 

for v = 1:m
    for j = 1:n
        if(I1(v,j)) > T
            im_salida(v,j) = 0;
        else
            im_salida(v,j) = 1;
        end
    end
end

imshow(im_salida)
lv=input('Quiere volver a elegir el valor del umbral? (S/N):','s');
end 

%Cortamos imagen y nos quedamos con lo que necesitamos
disp('Seleccione la fisura');
fis='S';
while fis=='S'
%selecciono la parte de la probeta a analizar y la guardo en 'a' para hacer lo mismo en todas las fotos   
[I2,b]=imcrop(im_salida);
imshow(I2) %muestra la imagen cortada
fis=input('Quiere volver a elegir la fisura? (S/N):','s');
end

%%Calculamos la longitud de la gelatina con la primera imagen (Todavía no esta deformada)
im_entrada = imread(names{1});
I1=imcrop(im_entrada,a);

%Calculo dimensiones imagen
[m,n] = size (I1);

%Creo una imagen de salida con fondo blanco con las dimensiones de la imagen de entrada
im_salida = ones(m,n);

for v = 1:m
    for j = 1:n
        if(I1(v,j)) > T
            im_salida(v,j) = 0;
        else
            im_salida(v,j) = 1;
        end
    end
end

%Cortamos la imagen
I2=imcrop(im_salida,b);
%Calculo dimensiones imagen cortada
[y,x] = size (I2);

%Con este bucle obtengo el pixel negro mas a la derecha y mas arriba y lo
%guardo para despues medir la posicion respecto a el
flag=0; %hay que meter un flag porque el break solo detiene un for 
for u = x:-1:1
        for w = 1:1:y 
            if(I2(w,u)) == 0 
                longitud_ref_derecha=u-1;
                altura_ref=w;
                flag=1;
                break           
            end
        end
    if(flag==1)
        break
    end
end

%Con este bucle obtengo el pixel negro mas a la izquierda y mas arriba y lo
%guardo para despues medir la posicion respecto a el
flag=0; %hay que meter un flag porque el break solo detiene un for 
for u = 1:1:x
        for w = 1:1:y 
            if(I2(w,u)) == 0 
                longitud_ref_izquierda=u+1;
                altura_ref_izquierda=w;
                flag=1;
                break           
            end
        end
    if(flag==1)
        break
    end
end

%Calculo de la longitud de la gelatina
longitud_gelatina = longitud_ref_derecha - longitud_ref_izquierda;
close all

%Declaramos las variables para crear la matriz
numero_foto=[];
tiempo=[];
longitud_fisura_1 = [];
longitud_fisura_mm_1 = [];
area=[];
area_mm2=[];
volumen=[];
volumen_mm3=[];
%Bala entra por el lado derecho de la gelatina
if lado == 'D' || lado == 'd'
    %Leemos las fotos y las tratamos
    for i = 1:p
        numero_foto=[numero_foto i];

        %Tiempo
        tiempo=[tiempo i/fps];

        %Leemos fotos
        A{i} = imread(names{i});
        I1=imcrop(A{i},a);

        %Calculo dimensiones imagen
        [m,n] = size (I1);

        %Creo una imagen de salida con fondo blanco con las dimensiones de la imagen de entrada
        im_salida = ones(m,n);

        %Con estos dos bucles voy recorriendo la imagen de entrada pixel por pixel y si el pixel de la imagen de 
        %entrada es mayor que el umbral T lo convierto en negro en la imagen de salida y si es menor que T en 
        %blanco 

        for v = 1:m
        for j = 1:n
            if(I1(v,j)) > T
                im_salida(v,j) = 0;
            else
                im_salida(v,j) = 1;
            end
        end
        end

        %Corto la imagen y me quedo con la parte que me interesa   
        I2bis = imcrop(im_salida,b);

        %Vemos como avanza la fisura en forma de video
        imshow(I2bis)

        %Declaramos las variables para crear la matriz
        largo=[];
        alto=[];

        %Con este for consigo calcular la longitud de la fisura
        for u = longitud_ref_derecha:-1:1
            num_pixeles=0;
            if(I2bis(1,u)) == 0
                largo=[largo (longitud_ref_derecha-u)];
                for w = 1:1:y 
                    if(I2bis(w,u)) == 0 
                        num_pixeles=num_pixeles+1;           
                    else
                       break;
                    end
                end
                for w = y:-1:1 
                    if(I2bis(w,u)) == 0 
                        num_pixeles=num_pixeles+1;
                    else
                        break;
                    end
                end
                alto=[alto (y-num_pixeles)];
            end
            if (num_pixeles >= y)
                largo=largo(1:(end-1));
                alto=alto(1:(end-1));
                break;
            end
        end

        %Determinamos la longitud de la fisura
        longitud_fisura_1 = [longitud_fisura_1 (longitud_ref_derecha-u-1)];
        %Conversion de logitud fisura de pixeles a mm
        longitud_fisura_mm_1 = (longitud_fisura_1 * longitud_gelatina_mm)/longitud_gelatina;

        %Determinamos el area
        area=[area sum(alto)];
        %Conversion de area en pixeles2 a mm2
        area_mm2 = (area * longitud_gelatina_mm)/longitud_gelatina;

        %Determinamos el volumen
        volumen=[volumen sum((pi*alto.^2)/4)];
        %Conversion de volumen en pixeles3 a mm3
        volumen_mm3 = (volumen * longitud_gelatina_mm)/longitud_gelatina;

    end
    
else 
    
%Bala entra por el lado izquierdo de la gelatina
    %Leemos las fotos y las tratamos
    for i = 1:p
        numero_foto=[numero_foto i];

        %Tiempo
        tiempo=[tiempo i/fps];

        %Leemos fotos
        A{i} = imread(names{i});
        I1=imcrop(A{i},a);

        %Calculo dimensiones imagen
        [m,n] = size (I1);

        %Creo una imagen de salida con fondo blanco con las dimensiones de la imagen de entrada
        im_salida = ones(m,n);

        %Con estos dos bucles voy recorriendo la imagen de entrada pixel por pixel y si el pixel de la imagen de 
        %entrada es mayor que el umbral T lo convierto en negro en la imagen de salida y si es menor que T en 
        %blanco 

        for v = 1:m
        for j = 1:n
            if(I1(v,j)) > T
                im_salida(v,j) = 0;
            else
                im_salida(v,j) = 1;
            end
        end
        end

        %Corto la imagen y me quedo con la parte que me interesa   
        I2bis = imcrop(im_salida,b);

        %Vemos como avanza la fisura en forma de video
        imshow(I2bis)

        %Declaramos las variables para crear la matriz
        largo=[];
        alto=[];

        %Con este for consigo calcular la longitud de la fisura
        for u = longitud_ref_izquierda:1:x
            num_pixeles=0;
            if(I2bis(1,u)) == 0
                largo=[largo (u-longitud_ref_izquierda)];
                for w = 1:1:y 
                    if(I2bis(w,u)) == 0 
                        num_pixeles=num_pixeles+1;           
                    else
                       break;
                    end
                end
                for w = y:-1:1 
                    if(I2bis(w,u)) == 0 
                        num_pixeles=num_pixeles+1;
                    else
                        break;
                    end
                end
                alto=[alto (y-num_pixeles)];
            end
            if (num_pixeles >= y)
                largo=largo(1:(end-1));
                alto=alto(1:(end-1));
                break;
            end
        end

        %Determinamos la longitud de la fisura
        longitud_fisura_1 = [longitud_fisura_1 (u-1-longitud_ref_izquierda)];
        %Conversion de logitud fisura de pixeles a mm
        longitud_fisura_mm_1 = (longitud_fisura_1 * longitud_gelatina_mm)/longitud_gelatina;

        %Determinamos el area
        area=[area sum(alto)];
        %Conversion de area en pixeles2 a mm2
        area_mm2 = (area * longitud_gelatina_mm)/longitud_gelatina;

        %Determinamos el volumen
        volumen=[volumen sum((pi*alto.^2)/4)];
        %Conversion de volumen en pixeles3 a mm3
        volumen_mm3 = (volumen * longitud_gelatina_mm)/longitud_gelatina;

    end
end

%Convertimos las matrices en columnas
Numero_foto = numero_foto';
Tiempo = tiempo';
Tiempo_s = Tiempo;
Longitud_fisura_1 = longitud_fisura_1';
Posicion_mm_1 = longitud_fisura_mm_1';
Area = area';
Area_mm2 = area_mm2';
Volumen = volumen';
Volumen_mm3 = volumen_mm3';
informacion = table(Numero_foto,Tiempo_s,Longitud_fisura_1,Posicion_mm_1)

%Declaramos las variables en caso de que usemos el parche
longitud_fisura_2 = [];
longitud_fisura_mm_2 = []; 
close all

%Parche que permite resolver el error en el calculo de la longitud
fis=input('Observa algun error en la longitud de fisura? (S/N):','s');
inicio=p+1;
if fis=='S'
    %Seleccionamos a partir de que imagen editar
    inicio=input('A partir de que imagen observa el error?:');

    %Bala entra por el lado derecho de la gelatina
    if lado == 'D' || lado == 'd'   
      for i = inicio:p  
        %Leemos fotos
        A{i} = imread(names{i});
        I1=imcrop(A{i},a);

        %Calculo dimensiones imagen
        [m,n] = size (I1);

        %Creo una imagen de salida con fondo blanco con las dimensiones de la imagen de entrada
        im_salida = ones(m,n);

        %Con estos dos bucles voy recorriendo la imagen de entrada pixel por pixel y si el pixel de la imagen de 
        %entrada es mayor que el umbral T lo convierto en negro en la imagen de salida y si es menor que T en 
        %blanco 

        for v = 1:m
        for j = 1:n
            if(I1(v,j)) > T
                im_salida(v,j) = 0;
            else
                im_salida(v,j) = 1;
            end
        end
        end

        %Corto la imagen y me quedo con la parte que me interesa   
        I2bis = imcrop(im_salida,b);

        %Vemos como avanza la fisura en forma de video
        imshow(I2bis)

        %Declaramos las variables para crear la matriz
        largo=[];
        alto=[];

        %Con este for consigo calcular la longitud de la fisura
        for w = 1:1:y 
            num_pixeles=0;
            for u = 1:1:longitud_ref_derecha 
                if(I2bis(w,u)) == 1
                    num_pixeles=num_pixeles+1;
                else
                    break;
                end   
            end
        largo=[largo num_pixeles];
        end
        vmin=min(largo);
        %Determinamos la longitud de la fisura
        longitud_fisura_2 = [longitud_fisura_2 (longitud_ref_derecha-vmin)];
        %Conversion de logitud fisura de pixeles a mm
        longitud_fisura_mm_2 = (longitud_fisura_2 * longitud_gelatina_mm)/longitud_gelatina;
      end
    
    %Bala entra por el lado izquierdo de la gelatina
    else 
       
      for i = inicio:p  
        %Leemos fotos
        A{i} = imread(names{i});
        I1=imcrop(A{i},a);

        %Calculo dimensiones imagen
        [m,n] = size (I1);

        %Creo una imagen de salida con fondo blanco con las dimensiones de la imagen de entrada
        im_salida = ones(m,n);

        %Con estos dos bucles voy recorriendo la imagen de entrada pixel por pixel y si el pixel de la imagen de 
        %entrada es mayor que el umbral T lo convierto en negro en la imagen de salida y si es menor que T en 
        %blanco 

        for v = 1:m
        for j = 1:n
            if(I1(v,j)) > T
                im_salida(v,j) = 0;
            else
                im_salida(v,j) = 1;
            end
        end
        end

        %Corto la imagen y me quedo con la parte que me interesa   
        I2bis = imcrop(im_salida,b);

        %Vemos como avanza la fisura en forma de video
        imshow(I2bis)

        %Declaramos las variables para crear la matriz
        largo=[];
        alto=[];

        %Con este for consigo calcular la longitud de la fisura
        for w = 1:1:y 
            num_pixeles=0;
            for u = x:-1:longitud_ref_izquierda 
                if(I2bis(w,u)) == 1
                    num_pixeles=num_pixeles+1;
                else
                    break;
                end   
            end
        largo=[largo num_pixeles];
        end
        vmin=min(largo);
        %Determinamos la longitud de la fisura
        longitud_fisura_2 = [longitud_fisura_2 (longitud_ref_derecha-vmin)];
        %Conversion de logitud fisura de pixeles a mm
        longitud_fisura_mm_2 = (longitud_fisura_2 * longitud_gelatina_mm)/longitud_gelatina;
      end  
   end   
end

%Convertimos las matrices en columnas
Longitud_fisura_2 = longitud_fisura_2';
Posicion_mm_2 = longitud_fisura_mm_2';

%Longitud con parche o sin parche
Longitud_fisura = [Longitud_fisura_1(1:(inicio-1))' Longitud_fisura_2']';
Posicion_mm = [Posicion_mm_1(1:(inicio-1))' Posicion_mm_2']';

%Dibujo grafica "Posicion respecto al tiempo" 
tamano=get(0,'ScreenSize');
figure('Name','Posicion respecto al tiempo','NumberTitle','off','position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
plot(Tiempo,Posicion_mm,'g');
title('Posicion respecto al tiempo')
xlabel('tiempo (s)')
ylabel('Posicion (mm)')

%Con esto obtengo las ecuaciones polinomicas
disp('El polinomio aproximado a los puntos es:');
hold on

%Polinomio grado 1
p1 = polyfit(Tiempo,Posicion_mm,1);
yp1 = polyval(p1,Tiempo);
%Calculo correlacion polinomio grado 1
yav1=mean(Posicion_mm);
s1 = sum((Posicion_mm-yav1).^2);
s1bis = sum((Posicion_mm-yp1).^2);
z1 = 1 - s1bis/s1
%Dibujo grafica polinomio grado 1
plot(Tiempo,yp1,'b')

%Polinomio grado 2
p2 = polyfit(Tiempo,Posicion_mm,2);
yp2 = polyval(p2,Tiempo);
%Calculo correlacion polinomio grado 2
r2 = corrcoef(Posicion_mm,yp2);
yav2=mean(Posicion_mm);
s2 = sum((Posicion_mm-yav2).^2);
s2bis = sum((Posicion_mm-yp2).^2);
z2 = 1 - s2bis/s2
%Dibujo grafica polinomio grado 2
plot(Tiempo,yp2,'m')

%Polinomio grado 3
p3 = polyfit(Tiempo,Posicion_mm,3)
yp3 = polyval(p3,Tiempo);
%Calculo correlacion polinomio grado 3
r3 = corrcoef(Posicion_mm,yp3);
yav3=mean(Posicion_mm);
s3 = sum((Posicion_mm-yav3).^2);
s3bis = sum((Posicion_mm-yp3).^2);
z3 = 1 - s3bis/s3
%Dibujo grafica polinomio grado 3
plot(Tiempo,yp3,'k')

%Polinomio grado 4
p4 = polyfit(Tiempo,Posicion_mm,4);
yp4 = polyval(p4,Tiempo);
%Calculo correlacion polinomio grado 4
r4 = corrcoef(Posicion_mm,yp4);
yav4=mean(Posicion_mm);
s4 = sum((Posicion_mm-yav4).^2);
s4bis = sum((Posicion_mm-yp4).^2);
z4 = 1 - s4bis/s4
%Dibujo grafica polinomio grado 4
plot(Tiempo,yp4,'r')
legend('original','grado1','grado2','grado3','grado4')

%Calculo de la Velocidad 
velocidad = diff(-p3);
Velocidad = polyval(velocidad, Tiempo);
Velocidad = Velocidad/1000;

%Calculo de la Aceleracion
aceleracion = diff(velocidad);
Aceleracion = polyval(aceleracion, Tiempo);
Aceleracion = Aceleracion/1000;

%Energia de la bala
Energia_proyectil=0.5*masa*Velocidad.^2;

%Dibujo grafica "Velocidad respecto al tiempo"
figure('Name','Velocidad respecto al tiempo','NumberTitle','off','position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
plot(Tiempo,Velocidad,'k');
title('Velocidad respecto al tiempo')
xlabel('tiempo (s)')
ylabel('Velocidad (m/s)')
legend('grado3')

%Dibujo grafica "Aceleracion respecto al tiempo"
figure('Name','Aceleracion respecto al tiempo','NumberTitle','off','position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
plot(Tiempo,Aceleracion,'k');
title('Aceleracion respecto al tiempo')
xlabel('tiempo (s)')
ylabel('Aceleracion (m/s^2)')
legend('grado3')

%Creamos la tabla donde almacenamos la informacion
Tiempo_s = Tiempo;
Longitud_fisura_pixeles = Longitud_fisura;
Area_pixeles2 = Area;
Volumen_pixeles3 = Volumen;
Velocidad_m_s = Velocidad;
Aceleracion_m_s2 = Aceleracion;
Energia_proyectil_J = Energia_proyectil;
Energia_cedida_J = -diff(Energia_proyectil);
Energia_cedida_J = [Energia_cedida_J;Energia_proyectil(end)];
informacion = table(Numero_foto,Tiempo_s,Longitud_fisura_pixeles,Posicion_mm,Area_pixeles2,Area_mm2,Volumen_pixeles3,Volumen_mm3,Velocidad_m_s,Aceleracion_m_s2,Energia_proyectil_J,Energia_cedida_J)

%Energia cedida total cedida por el proyectil al cuerpo
disp('La energia total cedida por el proyectil al cuerpo es:');
Energia_cedidatotal_J=(Energia_proyectil_J(1)-Energia_proyectil_J(end))

%Exportamos a un excel
filename = 'informacionBala.xlsx';
writetable(informacion,filename,'Sheet',1,'Range','B2')

%Asi vuelve al directorio original
cd(diract)