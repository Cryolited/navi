function [SatPos, GPSTime, TProp] = P72_GetSatPos(Data, inGPSTime, ...
    inTProp, Params) %#ok<INUSD>
%
% ������ ���������� ���������� ��������� �������� � ������ �������
% inGPSTime � ��������� ����� ��������������� ������� inTProp ��� ��������
% ��������� � ������� ECEF
%
% ������� ����������
%   Data - ���������, ����������, ��� �������, ��������� ��������� 1, 2 �
%     3;
%   inGPSTime - ����� ���������� �������;
%   inTProp - ����� ��������������� �������.
%
% �������� ����������
%   SatPos - ������ (8�1) ��������� � ���������� �������� ��� ���������
%       ���������:
%         [x; y; z; ... % ���������� � ������������� ������� ���������
%         xs_k; ys_k; i_k; ... % �������� ���������� ��������
%         Omega_k; % �������� �������� Omega_k
%         ZaZa]; % �������� ��� ��������� Omega_k � Omega_k_TProp
%   GPSTime - ����������������� ����� ���������� �������;
%   TProp - ����������������� ����� ��������������� �������.