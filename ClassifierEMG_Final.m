clear all;

r= raspi();
install_myo_mex;
build_myo_mex C:\myo-sdk-win-0.9.0\

global s1
global s2
global s3
global s4

% dedo médio 0/aberto 180/fechado
s1 = servo(r, 17, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2400e-6);
% polegar 0/aberto 180/fechado
s2 = servo(r, 16, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2400e-6);
% indidcador 0/fechado 180/aberto
s3 = servo(r, 20, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2400e-6);
% mínimo/anelar 0/fechado 180/aberto
s4 = servo(r, 21, 'MinPulseDuration', 500e-6, 'MaxPulseDuration', 2400e-6);


mm = MyoMex()
pause(5)

for k=1:inf
    % Pega o log de sinais a cada 3.5 segundos
    pause(3);
    m = mm.myoData.emg_log;
    
    % Confere os ultimos 5 segundos do log 
    mt = m(end-750:end-250,:);
    
     % Transforma o sinal 
    m2 = mt.*mt;
    
    mt3 = mt2./abs(mt);

    mt4 = mt3;

    mt4(isnan(mt4))=0;
    
    % Classifica o sinal (classificador)
    respm2 = classifyEMG3final(mt4);
    
    [s,~,j] = unique(respm2);

    % Movimento que foi lido mais vezes
    pdt2 = s{mode(j)}
    
    % Repetições de cada movimento lido no intervalo, e suas porcentagens
    y = groupcounts(respm2);
    % Porcentagem do movimento mais lido
    y_m = sum(y,"all");
    y_2 = max(y,[],1);
    prt = (y_2/y_m)*100;
    
    % Confere o movimento e se ele apareceu mais de 25% das vezes no sinal
    if (prt>=25)
        if (isequal(pdt2, 'punho'))
            disp('modelo mudou para o mão fechada')
            writePos(180, 180, 0, 0);
            pause(0.5);
        end
        
        if isequal(pdt2, 'indicador')
            disp('modelo mudou para o indicador')
            writePos(180, 180, 150, 0);
            pause(0.5);
        end
        
        if isequal(pdt2, 'garra')
            disp('modelo mudou para o garra')
            writePos(0, 0, 180, 180);
            pause(0.5);
        end
        
        if isequal(pdt2, 'pinca')
            disp('modelo mudou para o pinca')
            writePos(160, 165, 30, 180);
            pause(0.5);
        end
        
        if isequal(pdt2, 'polegar')
            disp('modelo mudou para o polegar')
            writePos(180, 20, 0, 0);
            pause(0.5);
        end
    else
        disp('nenhum movimento com 25%+ de ocorrencias')
    end
end

function writePos(p1, p2, p3, p4)
    global s1
    global s2
    global s3
    global s4
    
    writePosition(s1, p1);
    writePosition(s2, p2);
    writePosition(s3, p3);
    writePosition(s4, p4);
end
