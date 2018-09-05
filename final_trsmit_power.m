function [Rmax]  =  final_trsmit_power(CU,D2D)
B                        =                                 1;        
N0                       =                                 10^(-(174/10))*10^(-3)*B;    % 每个子载波的噪声功率-174dBm/Hz
global  num_mlti n R_SUM3;
global GAIN_C2BS GAIN_D2BS GAIN_D GAIN_C2D

%% 测试
%  global d_thrd a_thrd r1 r2 u k ;
% 
% r1                  =               500;                                      %基站半径
% r2                  =               90;                                       %社区大小
% u                   =               30;                                       %原始蜂窝人数
% k                   =               50;
% a_thrd              =               0.5;
% d_thrd              =               50;
% [GAIN_C2BS,GAIN_D2BS,GAIN_D,GAIN_C2D,~]  =            channel_gain(); 
% CU =1;
% D2D=1;

PMAX=0.251188643150958;
SINR_min=100;
z=num_mlti(D2D);
%%  选取D2D组SINR最小的接收者
F=[];
for rindex1=1:z
    F(rindex1)=GAIN_D(D2D,rindex1)/(GAIN_C2D(CU,D2D,rindex1)+N0);
end
 [~,rindex]=min( F);

 
 %y0:(p_c0,p_d0)
 p_c0=((GAIN_D(D2D,rindex)+GAIN_D2BS(1,D2D)*SINR_min)*SINR_min*N0)/(GAIN_D(D2D,rindex)*GAIN_C2BS(1,CU)-SINR_min*SINR_min*GAIN_C2D(CU,D2D,rindex)*GAIN_D2BS(1,D2D));
 p_d0=((GAIN_C2D(CU,D2D,rindex)*SINR_min+GAIN_C2BS(1,CU))*SINR_min*N0)/(GAIN_D(D2D,rindex)*GAIN_C2BS(1,CU)-SINR_min*SINR_min*GAIN_C2D(CU,D2D,rindex)*GAIN_D2BS(1,D2D));
 
 %y1:(p_c1,p_d1)
 p_c1=(SINR_min*(PMAX*GAIN_D2BS(1,D2D)+N0))/GAIN_C2BS(1,CU);
 p_d1=PMAX;
 
 %y2:(p_c2,p_d2)
 p_c2=PMAX;
 p_d2=(SINR_min*(PMAX*GAIN_C2D(CU,D2D,rindex)+N0))/GAIN_D(D2D,rindex);
 
 %y3:(p_c3,p_d3)
 p_c3=PMAX;
 p_d3=PMAX;
 
 %y4:(p_c4,p_d4)
 p_c4=PMAX;
 p_d4=(PMAX*GAIN_C2BS(1,CU)-SINR_min*N0)/(SINR_min*GAIN_D2BS(1,D2D));
 
 %y5:(p_c5,p_d5)
 p_c5=(PMAX*GAIN_D(D2D,rindex)-SINR_min*N0)/(SINR_min*GAIN_C2D(CU,D2D,rindex));
 p_d5=PMAX;
 
 %%%%%%%y1,y2,y3,y4,y5  R
 %首先给出yo :蜂窝用户的数据速率公式
 %y1 :
 R_C1                            =                                 25/n*1/log(2)  * log(1+( p_c1*GAIN_C2BS(1,CU)   ) / (    p_d1*GAIN_D2BS(1,D2D)+N0 )    );
 R_D1                            =                      25/n*num_mlti(D2D)/log(2)  * log(1+( p_d1*GAIN_D(D2D,rindex)   ) / (    p_c1*GAIN_C2D(CU,D2D,rindex)+N0   )    );
 R_SUM1                          =                          R_C1+R_D1;

 %y2 :
 R_C2                            =                                 25/n*1/log(2)  * log(1+( p_c2*GAIN_C2BS(1,CU)   ) / (    p_d2*GAIN_D2BS(1,D2D)+N0 )    );
 R_D2                            =                     25/n*num_mlti(D2D)/log(2)  * log(1+( p_d2*GAIN_D(D2D,rindex)   ) / (    p_c2*GAIN_C2D(CU,D2D,rindex)+N0   )    );
 R_SUM2                          =                          R_C2+R_D2;
 
 %y3 :
 R_C3                            =                                 25/n*1/log(2)  * log(1+( p_c3*GAIN_C2BS(1,CU)   ) / (    p_d3*GAIN_D2BS(1,D2D)+N0 )    );
 R_D3                            =                      25/n*num_mlti(D2D)/log(2)  * log(1+( p_d3*GAIN_D(D2D,rindex)   ) / (    p_c3*GAIN_C2D(CU,D2D,rindex)+N0   )    );
 R_SUM3                          =                          R_C3+R_D3;
 
 %y4 :
 R_C4                            =                                 25/n*1/log(2)  * log(1+( p_c4*GAIN_C2BS(1,CU)   ) / (    p_d4*GAIN_D2BS(1,D2D)+N0 )    );
 R_D4                            =                     25/n*num_mlti(D2D)/log(2)  * log(1+( p_d4*GAIN_D(D2D,rindex)   ) / (    p_c4*GAIN_C2D(CU,D2D,rindex)+N0   )    );
R_SUM4                          =                          R_C4+R_D4;

 %y5 :
 R_C5                            =                                 25/n*1/log(2)  * log(1+( p_c5*GAIN_C2BS(1,CU)   ) / (    p_d5*GAIN_D2BS(1,D2D)+N0 )    );
 R_D5                            =                      25/n*num_mlti(D2D)/log(2)  * log(1+( p_d5*GAIN_D(D2D,rindex)   ) / (    p_c5*GAIN_C2D(CU,D2D,rindex)+N0   )    );
 R_SUM5                          =                          R_C5+R_D5;

Rmax=0;
 if p_c0<=PMAX &&p_d0<=PMAX && p_d2<PMAX && p_c1<PMAX
     Rmax=max([R_SUM1,R_SUM2,R_SU。M3]);
 elseif p_c0<=PMAX &&p_d0<=PMAX && p_d2<PMAX && p_c4<PMAX
      Rmax=max([R_SUM2,R_SUM4]);
 elseif p_c0<=PMAX &&p_d0<=PMAX && p_c1<PMAX && p_c5<PMAX
      Rmax=max([R_SUM1,R_SUM5]);
 else  Rmax=0;
 end
 