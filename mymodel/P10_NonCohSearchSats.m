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
        'NumSats',       [], ... % Скаляр, количество найденных спутников
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
      inFile.Name = 'Z:\Методические материалы\СНС\MATLAB\Signals\30_08_2018__19_38_33_x02_1ch_16b_15pos_90000ms.dat';
      inFile.HeadLenInBytes = 0;
      inFile.NumOfChannels =1;
      inFile.ChanNum = 0;
      inFile.DataType = 'int16';
      inFile.Fs0= 2046e3;
      inFile.dF = 0 ;
      inFile.FsDown = 1;
      inFile.FsUp = 1;
      
      NumOfShiftedSamples = 0;
      NumOfNeededSamples = 2045;
    Signal = ReadSignalFromFile(inFile, NumOfShiftedSamples, NumOfNeededSamples);
    
    CACode = Gen

end