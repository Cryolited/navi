function Res = P10_NonCohSearchSats(inRes, Params)
%
% Функция когерентного поиска спутников в файле-записи
%
% Входные переменные
%   inRes - структура с результатами модели, объявленная в Main;
%
% Выходные переменные
%   Res - структура, которая отличается от inRes добавлением нового поля,
%       описание которого дано ниже в коде.

% Пересохранение результатов
    Res = inRes;

%% ИНИЦИАЛИЗАЦИЯ РЕЗУЛЬТАТА
    Search = struct( ...
        'NumSats',       0, ... % Скаляр, количество найденных спутников
        'SatNums',       [], ... % массив 1хNumSats с номерами найденных
            ... % спутников
        'SamplesShifts', [], ... % массив 1хNumSats, каждый элемент -
            ... % количество отсчётов, которые нужно пропустить в файле-
            ... % записи до начала первого периода CA-кода соответствующего
            ... % спутника
        'FreqShifts',    [], ... % массив 1хNumSats со значениями частотных
            ... % сдвигов найденных спутников в Гц
        'CorVals',       [], ... % массив 1хNumSats вещественных значений
            ... % пиков корреляционных функций нормированных на среднее
            ... % значение, по которым были найдены спутники
        'AllCorVals',    zeros(1, 32) ... % массив максимальных значений
            ... % всех корреляцион ных функций
    );

%% УСТАНОВКА ПАРАМЕТРОВ
    % Количество периодов, учитываемых при обнаружении.
        NumCA2Search = Params.P10_NonCohSearchSats.NumCA2Search;

    % Массив центральных частот анализируемых диапазонов, Гц
        CentralFreqs = Params.P10_NonCohSearchSats.CentralFreqs;

    % Порог обнаружения
        SearchThreshold = Params.P10_NonCohSearchSats.SearchThreshold;

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    Search.NumCA2Search    = NumCA2Search;
    Search.CentralFreqs    = CentralFreqs;
    Search.SearchThreshold = SearchThreshold;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Количество рассматрвиаемых частотных диапазонов
        NumCFreqs = length(CentralFreqs);

    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ
 
      
      NumOfShiftedSamples = 0;
      NumOfNeededSamples = 2*CALen-1;
      NumSatellite = 3; %32
      drawThreshold = 3; % Порог отрисовки значений, пока что свой(Search.SearchThreshold)
      drawFlag = 0; % Флаг отрисовки
      nonCohFlag = 1; % Флаг неког. обр.
      
    if (nonCohFlag == 1)
        NumRepeat = 10; % Опасно
    else
        NumRepeat = 1;
    end
    Cor3 = zeros( NumCFreqs, CALen );
    dt = 1 / Res.File.Fs;
    LastSat = 0;
    
for n=1:NumSatellite
    tic
    CACode = GenCACode(n,1);
    CACode2 = repelem(CACode,Res.File.R);
    CorAbs = zeros( NumCFreqs, CALen ); % обновление для накопления
    CorAbs2 = zeros( NumCFreqs, CALen );    
    for k=1:NumRepeat*2 % accumulation twice!! 
        NumOfShiftedSamples = (k-1)*(NumOfNeededSamples+1); % +1 чтоб совпадал сдвиг
        Signal = ReadSignalFromFile(Res.File, NumOfShiftedSamples, NumOfNeededSamples);
        for m=1:NumCFreqs
            freq = CentralFreqs(m);
            doppler = exp(1j*2*pi*freq*[1:length(CACode2)] * dt);
            CACodeM = CACode2 .* doppler;                
            Cor3(m,:) = conv(Signal,fliplr(CACodeM), 'valid');       
        end
        %disp([ max(max(abs(Cor3))) ,  mean(mean(abs(Cor3))), max(max(abs(Cor3)))/mean(mean(abs(Cor3)))]);
        if k <= NumRepeat
            CorAbs = CorAbs + abs(Cor3); % накопление 1 !!
        else
            CorAbs2 = CorAbs2 + abs(Cor3); % накопление 2 !!
        end
        
    end
    
    if (max(max(CorAbs)) > max(max(CorAbs2))) % У кого максимум выше
        MaxVal = max(max(CorAbs));
        CorVal = MaxVal/mean(mean(CorAbs));
    else
        CorAbs = CorAbs2;
        MaxVal = max(max(CorAbs2));
        CorVal = MaxVal/mean(mean(CorAbs2));
    end
    if ( CorVal > drawThreshold && LastSat ~= n )
        if ( drawFlag == 1 )
            figure();
            mesh(CorAbs);
        end   
        Search.NumSats = Search.NumSats + 1; 
        Search.CorVals(end+1) = CorVal;
        Search.SatNums(end+1) = n;
        
        [MaxFreq,MaxCA] = find(CorAbs==MaxVal);
        Search.FreqShifts(end+1) = CentralFreqs(MaxFreq);
        Search.SamplesShifts(end+1) = mod(MaxCA , CALen);
        LastSat = n;
    end
    Search.AllCorVals(n) = MaxVal;
    toc
end



end