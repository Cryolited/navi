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
        [Res.SubFrames.isSubFrameSync(NumSats), Res.SubFrames.BitSeqNum(NumSats),...
            Res.SubFrames.BitShift(NumSats)] = SubFrameSync(Res.Demod.Bits{NumSats,1}, 0);
        Res.SubFrames.Words{NumSats,1} = CheckFrames(Res.Demod.Bits{NumSats,1}(Res.SubFrames.BitSeqNum(NumSats),...
            Res.SubFrames.BitShift(NumSats) - 1:end));
end

end

function Words = CheckFrames(Bits)
%
% �� �������� ������ ���������� ��� ��������� �����, � ������ �����
% ����������� CRC ������� �����, ���� CRC �������, �� �����������
% �������������� �����, � ��������� ������ ����������� ������ ������
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
% ������� ����������� �������������
%
% isOk      - ����, �����������, ������� ������������� ��� ���, ������ ���
%   ������ ���� ������� ������ ���� ���!
% BitSeqNum - ����� ������� ������������������, ��� ������� �������
%   �������������. �.�. ������������������, � ������� ���� ������ ��������.
% BitShift  - ���������� ���, ������� ����� ���������� � �������
%   ������������������ �� ������ ��������.
Preamble = [1 0 0 0 1 0 1 1];% ��������� 10001011
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
% ������� ������������ �������� CRC ��� ������ ����� ��������������
% ���������

% �� �����:
%   EWord - ����� (������) � ����� ������ ����������� ����� � ������, �.�.
%     ����� 32 ����.

% �� ������: 
%   isOk - 1, ���� CRC ��������, 0 � ��������� ������.
%   DWord - �������������� ����� (������), �.�. ����� 24 ����.

EWord(3:26) = mod(EWord(3:26) + EWord(2),2); % ��������� �� ����� �������� 0,1

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