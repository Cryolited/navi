function UPos = P71_GetOneRXPos(Es, inGPSTimes, inTimeShifts, ...
    SampleNums, Params)
%
% ������� ������� ������ ������ ��������� ��������
%
% ������� ����������
%   Es - cell-������ � ����������� ���������;
%   inGPSTimes - ������� �������, � ������� ���� �������� ������� ��
%       ���������;
%   inTimeShifts - ������� �������� �������� ��������������� ��������
%       ��������� �� ����� ���������� ������������ ��������
%       ���������������;
%   SampleNums - ������ ��������, � ������� ������ ������� ��������� �
%       ������� ������� inGPSTimes.
%
% �������� ����������
%   UPos - ���������-��������� � ������:
%       x, y, z - ���������� � ������������� ���
%       T0 - ����� ������������ ������ �� �������
%       tGPSs, SampleNums - �������� ������� GPS ��� �������� �������� 
%       Lat, Lon, Alt - ������, �������, ������
%       SatsPoses - ���������� ���������, ������� �� ���������
%           x, y, z - ���������� � ������������� ���;
%           xs_k, ys_k, i_k - ���������� ����� ���������������� ��;
%           Lat, Lon, Alt - ������, �������, ������;
%           El, Az - ���� ��������� � ������;
%       NumIters, MaxNumIters - ����������� � ������������ ����� ��������;
%       Delta, MaxDelta - ����������� � ������������ �������� ������
%           ��������� ��������� ������������ ����� ��������� ����������
%           (�);
%       inGPSTimes, GPSTimes, inTimeShifts, TimeShifts - ����������
%           ���������� � ����������������� ����������.

%% ��������� ����������
    % ������������ ����� ��������
        MaxNumIters = Params.P71_GetOneRXPos.MaxNumIters;
    % ������������ ��������� ��������� ������������ ����� ���������
    % ���������� (�). ���� ����������� ��������� ������, �� ����
    % ���������������
        MaxDelta = Params.P71_GetOneRXPos.MaxDelta;

%% ��������� ��������
    % �������� �����, �/�
        c = 299792458;
    % ������ �����, �
        R = 6356863;

...
P72_GetSatPos
...
P73_RenewSatPos
...
P74_Cartesian2Spherical
...
P75_CalculateSatElAz