function Res = P30_NonCohDemodSatsSigs(inRes, Params)
%
% ������� ������������� ����������� �������� ���������
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
    Demod = struct( ...
        'Bits', {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������� cell-������� Bits - ������ 4�N �������� 0/1, ���
    %   N - ���������� ���������������� ���.

%% ��������� ����������

%% ���ר� ����������
    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

%% �������� ����� ������� - ���� �� ��������� ���������
% load('Rate2.mat');
    for k = 1: Res.Search.NumSats % ������� �1
    CAShift = Res.BitSync.CAShifts(k);
    CorVals = Res.Track.CorVals{k}(CAShift+1:end);% ���������� ������ �� ������� ���� 
    
%     % 1 �����������
%     dCorVals = CorVals(2:end) .* conj(CorVals(1:end-1)); % �������� ��� ����� ��������� ��������
%     figure
%     plot(angle(dCorVals)/pi); % ��� ������, ��� ���� "������"

%     % ������ �����������
%     ddCorVals = dCorVals(2:end) .* conj(dCorVals(1:end-1)); % ��� ��������, ����� ������������� ��������� ����
%     figure
%     plot(angle(ddCorVals)/pi, '.'); % �� ������ ��/2 ����� ������� �������
     %plot(real(ddCorVals)); % �� >< 0 ����� ������� �������, ��� ������ ����
% ======= ���� - ������ ���, ������ ������ ����������
    L = length(CorVals);
    NBits = floor(L/CAPerBit); % �������� �� ���-�� ���
    CorVals = CorVals(1:NBits*CAPerBit); % ����� ������, ������� ���-�� ���
     % 1 �����������
    dCorVals20 = CorVals(21:end) .* conj(CorVals(1:end-20));
%    figure
%    plot(angle(dCorVals20)/pi, '.'); % ����� ���� ���� ������, �� �������� ����� ��������� 20 ��������  
     % ���� ����������
    IntdCorVals20 = sum(reshape(dCorVals20, 20, []), 1); % ��������� �� ����� �� 20 ����������, � ������ ����� ���� ����������
%     figure
%     plot(angle(IntdCorVals20)/pi, '.'); % ��������, �� ���� ��� "������"
     % ������ �����������
    ddCorVals20 = IntdCorVals20(2:end) .* conj(IntdCorVals20(1:end-1)); 
%     figure
%     plot(angle(ddCorVals20)/pi, '.'); 
    
    ddBits = real(ddCorVals20)<0; % ������� �������
    dBits = [mod(cumsum([0 ,ddBits]), 2) ; mod(cumsum([1 ,ddBits]), 2)] ; % ��� ������� ��� ������ ��������������
    Bits = [mod(cumsum([[0;0] ,dBits],2), 2) ; mod(cumsum([[1;1] ,dBits],2), 2)] ; % 4 ������� ��� 2 ��������������
    Demod.Bits{k,1} = Bits([1 2],:); % �� ������ 2 �����������
    end
    Res.Demod = Demod;
end
    
    
  