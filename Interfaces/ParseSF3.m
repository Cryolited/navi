
allwords = Res.SubFrames.Words{1};

subframe3Num = 4;

Words = allwords(subframe3Num, :);

Data.C_ic = bi2de(Words{3}(1:16),'left-msb') * 2^-29; % comp
Data.Omega_0 = bi2de([ Words{3}(17:24) Words{4}(1:24)],'left-msb') * 2^-31; %comp
Data.C_is = bi2de(Words{5}(1:16),'left-msb') * 2^-29; % comp
Data.i_0 = bi2de([ Words{5}(17:24) Words{6}(1:24)],'left-msb') * 2^-31 ; %comp
Data.C_rc = bi2de(Words{7}(1:16),'left-msb') * 2^-5; % comp
Data.omega = bi2de([ Words{7}(17:24) Words{8}(1:24)],'left-msb') * 2^-31; %comp

Data.DOmega = bi2de(Words{9}(1:24),'left-msb') * 2^-43 ; % comp
Data.IODE = bi2de(Words{10}(1:8),'left-msb') ;
Data.IDOT = bi2de(Words{10}(9:22),'left-msb') * 2^-43 ; % comp

subframe2Num = 3;

Words = allwords(subframe2Num, :);

Data.Delta_n = bi2de(Words{4}(1:16),'left-msb') * 2^-43; % comp
Data.M_0 = bi2de([ Words{4}(17:24) Words{5}(1:24)],'left-msb') * 2^-31; %comp
Data.C_uc = bi2de(Words{6}(1:16),'left-msb') * 2^-29; % comp
Data.e = bi2de([ Words{6}(17:24) Words{7}(1:24)],'left-msb') * 2^-33; 
Data.C_us = bi2de(Words{8}(1:16),'left-msb') * 2^-29; % comp

Data.sqrtA = bi2de([ Words{8}(17:24) Words{9}(1:24)],'left-msb') * 2^-33; 
Data.t_oe = bi2de(Words{10}(1:16),'left-msb') * 2^-29; % comp
Data.Fit_Interval_Flag = Words{10}(17);
Data.AODO = bi2de(Words{10}(18:22),'left-msb') * 2^-29; % comp