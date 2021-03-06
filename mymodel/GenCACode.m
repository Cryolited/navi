function CACode = GenCACode(SigNum, NumCycles)
% 
% ������� ���������� �������� ����� �������� (������) C/A ���� ������� GPS,
% �.�. ������-������ ������ ������� 1023.
% 
% SigNum    - ����� ����, 1...63;
% NumCycles - ���������� �������� C/A ���� �� 1023 ������� (1...1000), ��
%   ��������� 
%
% CACode    - ������ ������ 1�NumCycles*1023, ���������� NumCycles ��������
%   C/A ����.
% test
   clc;
   clear all;
   close all;

    SigNum = 1;
    NumCycles = 1;
    a = [1 1 1 1 1 1 1 1 1 1] ;
    
    b = a;
    X1 = [0 1 1 0 0 1 0 1 1 1] ;
    n = length(a);

    for i = 1:1023
        G1(i) = a(10);
        c = xor(a(3), a(10)); 
        a = [c, a(1:n-1)]; 
        
        G21(i) = b(10); 
        d = mod(sum(b.*X1), 2);
        b = [d, b(1:n-1)] ; 
    end
  

    m = [5 6 7 8 17 18 139 140 141 251 252 254 255 256 257 258 469 470 471 ...
        472 473 474 509 512 513 514 515 516 859 860 861 862]; 
    G2 = circshift(G21, [0, m(SigNum)]);

   CACode = repmat(bitxor(G1, G2), [1, NumCycles]);
   CACode = CACode.*2-1;
subplot(2,1,1);
Cor= conv(CACode,fliplr(CACode), 'same');
plot(abs(Cor));
subplot(2,1,2);
Cor2 = conv([CACode, CACode, CACode,-CACode,-CACode,-CACode],fliplr(CACode), 'same');
plot(abs(Cor2));

f = -10e3:50:10e3;
CAmat = repmat(CACode,length(f), 1);
%doppler = cos(2*pi*f'*[1:length(CAmat)]/1e5);
doppler = exp(1j*2*pi*f'*[1:length(CAmat)]/1e6);
CAmat2 = CAmat .* doppler;
Cor3 = conv2(CAmat2,fliplr(CACode), 'same');
figure;
mesh(abs(Cor3));
end