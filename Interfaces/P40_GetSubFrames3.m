function Res = P40_GetSubFrames(inRes, Params)
%
% Функция некогерентного трекинга спутников и битовой синхронизации
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
    SubFrames = struct( ...
        'isSubFrameSync', zeros(Res.Search.NumSats, 1), ... 
        'BitSeqNum',      zeros(Res.Search.NumSats, 1), ...
        'BitShift',       zeros(Res.Search.NumSats, 1), ...
        'Words',          {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждый элемент массива isSubFrameSync - флаг успешности подкадровой
    %   синхронизации.
    % Каждый элемент массива BitSeqNum - номер битового потока, в котором
    %   удалось выполнить синхронизацию с началом подкадра.
    % Каждый элемент массива BitShift - количество бит, которые надо
    %   пропустить от начала битового потока до начала первого подкадра.
    % Каждая ячейка cell-массива Words - cell-массив (Nx10), где N -
    %   количество обработанных подкадров, каждая ячейка - массив 1х24 бит
    %   декодированного слова, если CRC сошлось, и пустой массив, если CRC
    %   не сошлось.

%% УСТАНОВКА ПАРАМЕТРОВ

%% РАСЧЁТ ПАРАМЕТРОВ

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ
for NumSats = 1:Res.Search.NumSats
        [Res.SubFrames.isSubFrameSync(NumSats), Res.SubFrames.BitSeqNum(NumSats),...
            Res.SubFrames.BitShift(NumSats)] = SubFrameSync(Res.Demod.Bits{NumSats,1}, 0);
        Res.SubFrames.Words{NumSats,1} = CheckFrames(Res.Demod.Bits{NumSats,1}(Res.SubFrames.BitSeqNum(NumSats),...
            Res.SubFrames.BitShift(NumSats) - 1:end));
end

end

function Words = CheckFrames(Bits)
%
% Из битового потока выделяются все возможные кадры, в каждом кадре
% проверяется CRC каждого слова, если CRC сошлось, то сохраняется
% декодированное слово, в противном случае сохраняется пустой массив
NumSubFrames = floor(length(Bits) / 300);
NumWords = 10;
Words = cell(NumSubFrames, NumWords);
for nsf = 1:NumSubFrames
        for nw = 1:NumWords
            [~, DWord] = CheckCRC(Bits(((nsf-1) * 300) + ((nw-1) * 30) + 1:...
                ((nsf-1) * 300) + ((nw-1) * 30) + 32));
            Words{nsf, nw} = DWord;
        end
end
end

function [isOk,BitSeqNum, BitShift] = SubFrameSync(Bits, isDraw)
%     function [isOk, BitSeqNum, BitShift] = SubFrameSync(Bits, isDraw, ...
%     SaveDirName, SatNum)
%
% Функция подкадровой синхронизации
%
% isOk      - флаг, указывающий, найдена синхронизация или нет, причём она
%   должна быть найдена только один раз!
% BitSeqNum - номер битовой последовательности, для которой найдена
%   синхронизация. т.е. последовательности, с которой надо дальше работать.
% BitShift  - количество бит, которые нужно пропустить в битовой
%   последовательности до начала подкадра.
Preamble = [1 0 0 0 1 0 1 1];% Преамбула 10001011
CorPreamble = zeros(2, 300);
    isOk = 0;
    %
    for NumStr = 1:2
        CorPreamble(NumStr,:) = conv(Bits(NumStr, 1:307)*2-1, fliplr(Preamble*2-1), 'valid');
        PreBitShift = find(abs(CorPreamble(NumStr,:)) == 8);
        if (PreBitShift)
            for n = 1:length(PreBitShift)
                [isOkCRC1, ~] = CheckCRC(Bits(NumStr,(PreBitShift(n)-2) : (PreBitShift(n) + 29)));
                [isOkCRC2, ~] = CheckCRC(Bits(NumStr,(PreBitShift(n)-2+30) : (PreBitShift(n) + 29 + 30)));
                if (isOkCRC1 == 1 && isOkCRC2 == 1)
                    isOk = 1;
                    BitSeqNum = NumStr;
                    BitShift = PreBitShift(n) - 1;
                end
            end
        end
    end
end

function [isOk, DWord] = CheckCRC(EWord)
% Функиця осуществляет проверку CRC для одного слова навигационного
% сообщения

% На входе:
%   EWord - слово (строка) с двумя битами предыдущего слова в начале, т.е.
%     всего 32 бита.

% На выходе: 
%   isOk - 1, если CRC сходится, 0 в противном случае.
%   DWord - декодированное слово (строка), т.е. всего 24 бита.

EWord(3:26) = mod(EWord(3:26) + EWord(2),2); % Избавляет от учета инверсии 0,1

DWord(25) = mod(EWord(1) + sum(EWord([1 2 3 5 6 10 11 12 13 14 17 18 20 23] + 2)),2);
DWord(26) = mod(EWord(2) + sum(EWord([2 3 4 6 7 11 12 13 14 15 18 19 21 24] + 2)),2);
DWord(27) = mod(EWord(1) + sum(EWord([1 3 4 5 7 8 12 13 14 15 16 19 20 22] + 2)),2);
DWord(28) = mod(EWord(2) + sum(EWord([2 4 5 6 8 9 13 14 15 16 17 20 21 23] + 2)),2);
DWord(29) = mod(EWord(2) + sum(EWord([1 3 5 6 7 9 10 14 15 16 17 18 21 22 24] + 2)),2);
DWord(30) = mod(EWord(1) + sum(EWord([3 5 6 8 9 10 11 13 15 19 22 23 24] + 2)),2);

isOk = isequal(DWord(25:30), EWord(27:32));
 
if (isOk)
    DWord = EWord(3:26);
else
    DWord = []; 
end

end