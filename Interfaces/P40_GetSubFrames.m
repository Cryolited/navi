function Res = P40_GetSubFrames(inRes, Params)
%
% ������� �������������� �������� ��������� � ������� �������������
%
% ������� ����������
%   inRes - ��������� � ������������ ������, ����������� � Main;
%
% �������� ����������
%   Res - ���������, ������� ���������� �� inRes ����������� ������ ����,
%       �������� �������� ���� ���� � ����.

% �������������� �����������
    Res = inRes;

%% ������������� ����������
    SubFrames = struct( ...
        'isSubFrameSync', zeros(Res.Search.NumSats, 1), ... 
        'BitSeqNum',      zeros(Res.Search.NumSats, 1), ...
        'BitShift',       zeros(Res.Search.NumSats, 1), ...
        'Words',          {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������� ������� isSubFrameSync - ���� ���������� �����������
    %   �������������.
    % ������ ������� ������� BitSeqNum - ����� �������� ������, � �������
    %   ������� ��������� ������������� � ������� ��������.
    % ������ ������� ������� BitShift - ���������� ���, ������� ����
    %   ���������� �� ������ �������� ������ �� ������ ������� ��������.
    % ������ ������ cell-������� Words - cell-������ (Nx10), ��� N -
    %   ���������� ������������ ���������, ������ ������ - ������ 1�24 ���
    %   ��������������� �����, ���� CRC �������, � ������ ������, ���� CRC
    %   �� �������.

%% ��������� ����������

%% ���ר� ����������

%% �������� ����� ������� - ���� �� ��������� ���������
for NumSats = 1:Res.Search.NumSats
        SatsBits = Res.Demod.Bits{NumSats,1};
        [SubFrames.isSubFrameSync(NumSats),...
            SubFrames.BitSeqNum(NumSats),...
            SubFrames.BitShift(NumSats)] = SubFrameSync(SatsBits, 0);
        
        StrNum = SubFrames.BitSeqNum(NumSats);
        Bits = SatsBits(StrNum, SubFrames.BitShift(NumSats) - 1:end);
        SubFrames.Words{NumSats,1} = CheckFrames(Bits);
        
        
end
    Res.SubFrames = SubFrames;
end

function Words = CheckFrames(Bits)
%
% �� �������� ������ ���������� ��� ��������� �����, � ������ �����
% ����������� CRC ������� �����, ���� CRC �������, �� �����������
% �������������� �����, � ��������� ������ ����������� ������ ������
NumBits = 300; % ��� � ��������
NumSubFrames = floor(length(Bits) / NumBits);
NumWords = 10;
Words = cell(NumSubFrames, NumWords);
for nsf = 1:NumSubFrames
        for nw = 1:NumWords
            ind = ((nsf-1) * 300) + ((nw-1) * 30) + 1: ((nsf-1) * 300) + ((nw-1) * 30) + 32;
            [~, DWord] = CheckCRC(Bits(ind));
            Words{nsf, nw} = DWord;
        end
end
end

function [isOk, BitSeqNum, BitShift] = SubFrameSync(Bits, isDraw, ...
    SaveDirName, SatNum)
%
% ������� ����������� �������������
%
% isOk      - ����, �����������, ������� ������������� ��� ���, ������ ���
%   ������ ���� ������� ������ ���� ���!
% BitSeqNum - ����� ������� ������������������, ��� ������� �������
%   �������������. �.�. ������������������, � ������� ���� ������ ��������.
% BitShift  - ���������� ���, ������� ����� ���������� � �������
%   ������������������ �� ������ ��������.

% load('Rate2.mat');
% load('Rate2_Original13.mat');
% Bits = Res.Demod.Bits{1};


preamb = [0 0 1 0 0 0 1 0 1 1]*2-1;
isOk = 0;
BitSeqNum = 0;
BitShift = -1;
%EWord = Bits(Str, BitShift(n) + [-2:29]); % 2 ����� ��� �������, 5 ������ ��� ������ CRC

    for StrNum = 1:2
        partBits = Bits(StrNum,1:300+10-1)*2-1;
        Cor = conv(partBits,fliplr(preamb), 'valid');
        BitShift = find(abs(Cor) == 10) + 2; % +2 �� ��������� 8���, � �� 10
        for n = 1:length(BitShift)
            [isOkCRC1, ~] = CheckCRC(Bits(StrNum, BitShift(n) + [-2:29]));% 2 ����� ��� �������, 5 ������ ��� ������ CRC
            if (isOkCRC1)
                [isOkCRC2, ~] = CheckCRC(Bits(StrNum, BitShift(n) + [-2:29] + 30));
                if (isOkCRC2)
                    isOk = 1;
                    BitSeqNum = StrNum;
                    BitShift = BitShift(n) - 1;
                end
            end
        end
    end

end

function [isOk, DWord] = CheckCRC(EWord)
% ������� ������������ �������� CRC ��� ������ ����� ��������������
% ���������

% �� �����:
%   EWord - ����� (������) � ����� ������ ����������� ����� � ������, �.�.
%     ����� 32 ����.

% �� ������: 
%   isOk - 1, ���� CRC ��������, 0 � ��������� ������.
%   DWord - �������������� ����� (������), �.�. ����� 24 ����.

%1) ��������� ����� � ��������� ����� ���������� �����
CheckWord = mod(EWord(2) + EWord(2 + [1:24])  ,2); 

%2) �������
D25(1) = mod(EWord(1) + sum(CheckWord([1 2 3 5 6 10 11 12 13 14 17 18 20 23])),2);
D25(2) = mod(EWord(2) + sum(CheckWord([2 3 4 6 7 11 12 13 14 15 18 19 21 24] )),2);
D25(3) = mod(EWord(1) + sum(CheckWord([1 3 4 5 7 8 12 13 14 15 16 19 20 22] )),2);
D25(4) = mod(EWord(2) + sum(CheckWord([2 4 5 6 8 9 13 14 15 16 17 20 21 23] )),2);
D25(5) = mod(EWord(2) + sum(CheckWord([1 3 5 6 7 9 10 14 15 16 17 18 21 22 24] )),2);
D25(6) = mod(EWord(1) + sum(CheckWord([3 5 6 8 9 10 11 13 15 19 22 23 24] )),2);

isOk = isequal(D25, EWord(end-5:end));
DWord = []; 

if (isOk)
    DWord = CheckWord; %EWord(2 + [1:24])
end

end
