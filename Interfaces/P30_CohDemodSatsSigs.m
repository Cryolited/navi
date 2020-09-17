function Res = P30_CohDemodSatsSigs(inRes, Params)
%
% ������� ����������� ����������� �������� ���������
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
    % ������ ������� cell-������� Bits - ������ 1�N �������� 0/1, ���
    %   N - ���������� ���������������� ���.

%% ��������� ����������

%% ���ר� ����������
    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

%% �������� ����� ������� - ���� �� ��������� ���������