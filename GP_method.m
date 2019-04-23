%function [Solution_up,Solution_down,Need_RC_up,Need_RC_down,R_CU_UP,R_CU_DOWN,Need_RD_up,Need_RD_down] = GP_method(CUE, DUE)

%代码功能  ：   使用几个规划，解决用户的功率分配问题
%输入参数  ：   CUE、DUE 的 SINR阈值需求，用户的最大功率
%输出参数  ：   CUE、DUE的最后的输出功率

% CUE =1;
% DUE =1;
%cla(1)
%% 下面是用户SINR阈值测试参数
%   log2(1+1)                        =                            1            (bps/Hz)
%   log2(1+10^0.7) ;             =                            2.5878   (bps/Hz)
%   log2(1+60)                      =                            5.9307   (bps/Hz)
%   log2(1+600)                    =                            9.2312   (bps/Hz)
%   log2(1+6000)                  =                            12.5510 (bps/Hz)
%   设定 SINR 的阈值要根据具体的需求，可以考虑

%% 下面定义CUE 和 DUE 的SINR阈值
S_i                                         =                            10^0.7;                                                                                                                   % 蜂窝用户上行链路所需的数据速率和D2D用户的数据速率都是 7 dB
S_jup                                     =                            10^0.7;    
S_jdown                                =                            10^0.7;             

%% 所需的数据速率
REQ_C                                   =                             log2(1+10^0.7) ;
REQ_D                                   =                             log2(1+10^0.7) ;



%% 高斯白噪声
B                                           =                                 1;                                                                                                                       % 单位带宽
N0                                        =                                 10^(-(174/10))*10^(-3)*B;                                                                                 % 每个子载波的噪声功率-174dBm/Hz

%% 下面是移动终端用户和基站的最大的发送功率
Puser                                     =                            0.251188643150958;                                                                                                                             % 24dBm 移动终端用户，包括蜂窝用户和D2D用户的最大发送功率为23dBm 
PBS                                       =                            39.810717055349755;                                                                                                                           % 46dBm  基站的发送功率较大，本文使用43dBm            

%% 调用信道增益函数，得到各用户之间的信道增益数值
[GAIN_C_UP,GAIN_C_DOWN,GAIN_D2BS,GAIN_BS2D,GAIN_D_UP,GAIN_D_DOWN,GAIN_C2D,GAIN_D2C]  =  final_version_channel_gain();

%% 初始化蜂窝和D2D匹配以后的数据速率 
R_ij                                        =                             0;

%% 下面计算出当未被复用时，蜂窝用户的数据速率
p_up                                      =                            Puser;
p_do                                      =                            PBS;
R_CU_UP                               =                            log2(1+(GAIN_C_UP*p_up)/(N0));                                                                              % 各蜂窝用户上行链路数据速率
R_CU_DOWN                        =                            log2(1+(GAIN_C_DOWN*p_do)/(N0));                                                                        % 各蜂窝用户下行链路数据速率

R_CU                                     =                            [R_CU_UP; R_CU_DOWN];
  
up                                         =                            sum(R_CU_UP);
do                                         =                            sum(R_CU_DOWN);                                                                                                   % 经验证，由于下行通信基站的功率较大，所以 d


%% 测试用户匹配以后各自的数据速率
before_reuse_R_C_UP            =                              R_CU_UP(1,CUE);
R_C_UP                                 =                              log2( 1+ ( Puser * GAIN_C_UP(1,CUE) )  /  ( Puser *  GAIN_D2BS(DUE,CUE) + N0 ) );
R_D                                       =                              log2( 1+ ( Puser * GAIN_D_UP(DUE,1,CUE) )  /  ( Puser * GAIN_C2D(CUE,DUE) + N0 ) );

%% 下面计算  Y_0  点的坐标值
Y0_i                                       =                             (  N0 * S_i * ( S_jup * GAIN_C2D(CUE,DUE) + GAIN_C_UP(1,CUE) )  ) / ( GAIN_D_UP(DUE,1,CUE) * GAIN_C_UP(1,CUE) - GAIN_D2BS(DUE,CUE) * GAIN_C2D(CUE,DUE) * S_jup *  S_i);                                           
Y0_j                                       =                             (  N0 * S_jup * ( S_i * GAIN_D2BS(DUE,CUE) + GAIN_D_UP(DUE,1,CUE) ) / (  GAIN_D_UP(DUE,1,CUE) * GAIN_C_UP(1,CUE)  - ( S_jup *  S_i * GAIN_C2D(CUE,DUE) * GAIN_D2BS(DUE,CUE) ) ));
Y0                                         =                             [ Y0_j   Y0_i];
%% 下面计算 Y_1  点的坐标值
Y1_i                                       =                             Puser;
Y1_j                                       =                             ( S_jup * ( Puser * GAIN_D2BS(DUE,CUE)+ N0 ) )  /  GAIN_C_UP(1,CUE);
Y1                                         =                             [Y1_j   Y1_i];

%% 下面计算 Y_2  点的坐标值
Y2_i                                       =                             ( S_i * ( Puser * GAIN_C2D(CUE,DUE)+ N0 ) ) /  GAIN_D_UP(DUE,1,CUE);
Y2_j                                       =                             Puser;
Y2                                         =                             [ Y2_j  Y2_i];

%% 下面计算 Y_3  点的坐标值
Y3_i                                       =                             Puser  ;
Y3_j                                       =                             Puser ;
Y3                                         =                             [Y3_j   Y3_i];

%% 下面计算 Y_4  点的坐标值
Y4_i                                       =                             ( Puser * GAIN_C_UP(1,CUE) - N0 * S_jup )  /  ( S_jup * GAIN_D2BS(DUE,CUE)   );
Y4_j                                       =                             Puser ;
Y4                                         =                             [Y4_j   Y4_i];

%% 下面计算 Y_5  点的坐标值
Y5_i                                       =                             Puser ;
Y5_j                                       =                             ( Puser * GAIN_D_UP(DUE,1,CUE) - N0 * S_i )  /  (  S_i * GAIN_C2D(CUE,DUE)    );
Y5                                         =                             [Y5_j   Y5_i];


%% 把各个点的坐标值，汇总放在一起
Point_i                                 =                             [ Y1_i   Y2_i   Y3_i   Y4_i   Y5_i];
Point_j                                 =                             [ Y1_j   Y2_j   Y3_j   Y4_j   Y5_j];

%% 计算出匹配以后的数据速率，在各个点取值时候的值
R_sum_up                             =                             zeros(5,3);
for point=1:5
    R_CUE                               =                             log2( 1+ ( Point_j(1,point) * GAIN_C_UP(1,CUE) )  /  ( Point_i(1,point) *  GAIN_D2BS(DUE,CUE) + N0 ) );  
    R_DUE                               =                             log2( 1+ ( Point_i(1,point) * GAIN_D_UP(DUE,1,CUE) )  /  ( Point_j(1,point) * GAIN_C2D(CUE,DUE) + N0 ) );
    sum1                                 =                             R_CUE+R_DUE;
    R_sum_up(point,1)             =                             sum1;
    R_sum_up(point,2)             =                             R_CUE;
    R_sum_up(point,3)             =                             R_DUE;
end

for point=1:5
    if R_sum_up(point,2)  <  REQ_C     
        R_sum_up(point,:)           =                             0;
    end
    
    if R_sum_up(point,3)  <  REQ_D
        R_sum_up(point,:)           =                             0;
    end
end

%% 筛选出合理的功率值，将不合理的值置为0, 分为三种情况进行讨论

%% case 1, 在1,2,3,点处取得最优值
if Y2_i < Puser && Y1_j < Puser
    R_sum_up(4,:)           =                             0;
    R_sum_up(5,:)           =                             0;
end

%% case 2, 在1,5,点取得最优值
if Y5_j < Puser && Y1_j < Puser
    R_sum_up(2,:)           =                             0;
    R_sum_up(3,:)           =                             0;
    R_sum_up(4,:)           =                             0;
end

%% case 3, 在2,4,点取得最优值
if Y2_i  < Puser &&  Y4_i < Puser
    R_sum_up(1,:)           =                             0;
    R_sum_up(3,:)           =                             0;
    R_sum_up(5,:)           =                             0;
end 

Solution_up                            =                             max( max( R_sum_up(:,1) ) );

[D_index  C_index]                  =                             find( R_sum_up==  max( max( R_sum_up(:,1) ) ) );    


Need_point_up                       =                             D_index(1);

Need_RD_up                           =                             log2( 1+ ( Point_i(1,Need_point_up) * GAIN_D_UP(DUE,1,CUE) )  /  ( Point_j(1,Need_point_up) * GAIN_C2D(CUE,DUE) + N0 ) );

Need_RC_up                           =                             log2( 1+ ( Point_j(1,Need_point_up) * GAIN_C_UP(1,CUE) )  /  (  N0 ) );  

R_Q_C                                     =                              log2( 1+ ( Point_j(1,Need_point_up) * GAIN_C_UP(1,CUE) )  /  ( N0 ) );  

Solution_up                            =                             Solution_up -  R_CU_UP(1,CUE);



%% 如果两者不能形成匹配
if Y0_j > Puser  |  Y0_i >Puser  
    Solution_up                        =                              0;
end

if Solution_up <= 0
    Need_RD_up=0; 
    Solution_up  =0;
    Need_RC_up                           =                          log2( 1+ (Puser * GAIN_C_UP(1,CUE) )  /  (   N0 ));  
end






%% 通过画图程序，检验得到的值知否是正确的解
%  axis([0 0.3 0 0.3])
%  grid on
%  plot ( Y0,  Y1 );
%  hold on 
%  plot ( Y0,  Y5 );
%  hold on 
%  plot(  [0.2,0.2], [0,0.3 ] )
%  hold on 
%  plot(  [0,0.3], [0.2,0.2 ] )
%  hold on
%  
%  plot(Y0_i,Y0_j,'o','color','g'   )
%  plot(Y1_i,Y1_j,'o','color','g'   )
%  plot(Y2_i,Y2_j,'o','color','g'   )
%  plot(Y3_i,Y3_j,'o','color','g'   )
%  plot(Y4_i,Y4_j,'o','color','g'   )
%  plot(Y5_i,Y5_j,'o','color','g'   )     
% 
%  text(Y0_i,Y0_j,'Y0'   )
%  text(Y1_i,Y1_j,'Y1'   )
%  text(Y2_i,Y2_j,'Y2'   )
%  text(Y3_i,Y3_j,'Y3'   )
%  text(Y4_i,Y4_j,'Y4'   )
%  text(Y5_i,Y5_j,'Y5'   )








%% 下面程序是，D2D用户复用蜂窝用户下行链路的子载波时，求系统获得数据速率的总和

%% 下面计算  Y_0  点的坐标值
%Y0_i_DOWN                                 =                             (  N0 * S_i * ( S_jdown * GAIN_BS2D(DUE,CUE) + GAIN_C_DOWN(1,CUE) )  ) / ( GAIN_D_DOWN(DUE,1,CUE) * GAIN_C_DOWN(1,CUE) - GAIN_D2C(CUE,DUE) * GAIN_BS2D(DUE,CUE) * S_jdown *  S_i);                                           
%Y0_j_DOWN                                 =                             (  N0 * S_jdown * ( S_i * GAIN_D2C(CUE,DUE) + GAIN_D_DOWN(DUE,1,CUE) ) / (  GAIN_D_DOWN(DUE,1,CUE) * GAIN_C_DOWN(1,CUE)  - ( S_jdown *  S_i * GAIN_BS2D(DUE,CUE) * GAIN_D2C(CUE,DUE) ) ));
%Y0_DOWN                                   =                             [ Y0_j_DOWN   Y0_i_DOWN];
%% 下面计算 Y_1  点的坐标值
Y1_i_DOWN                                    =                             Puser;
Y1_j_DOWN                                    =                             ( S_jdown * ( Puser * GAIN_D2C(CUE,DUE) + N0 ) )  /  GAIN_C_DOWN(1,CUE);
Y1_DOWN                                      =                             [Y1_j_DOWN   Y1_i_DOWN];

%% 下面计算 Y_2  点的坐标值
Y2_i_DOWN                                    =                             ( S_i * ( PBS * GAIN_BS2D(DUE,CUE) + N0 ) ) /  GAIN_D_DOWN(DUE,1,CUE);
Y2_j_DOWN                                    =                             PBS;
Y2_DOWN                                      =                             [ Y2_j_DOWN  Y2_i_DOWN];

%% 下面计算 Y_3  点的坐标值
Y3_i_DOWN                                    =                             Puser  ;
Y3_j_DOWN                                    =                             PBS ;
Y3_DOWN                                      =                             [Y3_j_DOWN   Y3_i_DOWN];

%% 下面计算 Y_4  点的坐标值
Y4_i_DOWN                                     =                             ( PBS * GAIN_C_DOWN(1,CUE) - N0 * S_jdown )  /  ( S_jdown * GAIN_D2C(CUE,DUE)   );
Y4_j_DOWN                                     =                             PBS ;
Y4_DOWN                                       =                             [Y4_j_DOWN   Y4_i_DOWN];

%% 下面计算 Y_5  点的坐标值
Y5_i_DOWN                                     =                             Puser ;
Y5_j_DOWN                                     =                             ( Puser * GAIN_D_DOWN(DUE,1,CUE) - N0 * S_i )  /  (  S_i * GAIN_BS2D(DUE,CUE)    );
Y5_DOWN                                       =                             [Y5_j_DOWN   Y5_i_DOWN];

%% 把各个点的坐标值，汇总放在一起
Point_i_DOWN                                 =                             [ Y1_i_DOWN   Y2_i_DOWN   Y3_i_DOWN   Y4_i_DOWN   Y5_i_DOWN];
Point_j_DOWN                                 =                             [ Y1_j_DOWN   Y2_j_DOWN   Y3_j_DOWN   Y4_j_DOWN   Y5_j_DOWN];


%% 计算出匹配以后的数据速率，在各个点取值时候的值
R_sum_down                                      =                             zeros(5,3);
for point=1:5
    R_CUE1                                            =                             log2( 1+ ( Point_j_DOWN(1,point) * GAIN_C_DOWN(1,CUE) )  /  ( Point_i_DOWN(1,point) *  GAIN_D2C(CUE,DUE) + N0 ) );  
    R_DUE1                                            =                             log2( 1+ ( Point_i_DOWN(1,point) * GAIN_D_DOWN(DUE,1,CUE) )  /  ( Point_j_DOWN(1,point) * GAIN_BS2D(DUE,CUE) + N0 ) );
    sum1                                             =                             R_CUE+R_DUE;
    R_sum_down(point,1)                     =                             sum1;
    R_sum_down(point,2)                     =                             R_CUE1;
    R_sum_down(point,3)                     =                             R_DUE1;
end

for point=1:5
    if R_sum_down(point,2)  <  REQ_C     
        R_sum_down(point,:)                  =                             0;
    end
    
    if R_sum_down(point,3)  <  REQ_D
        R_sum_down(point,:)                  =                             0;
    end
end

%% 筛选出合理的功率值，将不合理的值置为0, 分为三种情况进行讨论

%% case 1, 在1,2,3,点处取得最优值
if Y2_i_DOWN < Puser && Y1_j_DOWN < PBS
    R_sum_down(4,:)           =                             0;
    R_sum_down(5,:)           =                             0;
end

%% case 2, 在1,5,点取得最优值
if Y5_j_DOWN < PBS && Y1_j_DOWN < PBS
    R_sum_down(2,:)           =                             0;
    R_sum_down(3,:)           =                             0;
    R_sum_down(4,:)           =                             0;
end

%% case 3, 在2,4,点取得最优值
if Y2_i_DOWN  < Puser &&  Y4_i_DOWN < Puser
    R_sum_down(1,:)           =                             0;
    R_sum_down(3,:)           =                             0;
    R_sum_down(5,:)           =                             0;
end

Solution_down                                  =                             max( max( R_sum_down(:,1) ) );

[D_index1  C_index1]                         =                             find( R_sum_down==  max( max( R_sum_down(:,1) ) ) );    
 

Need_point_down                              =                             D_index1(1);

Need_RD_down                                  =                             log2( 1+ ( Point_i_DOWN(1,Need_point_down) * GAIN_D_DOWN(DUE,1,CUE) )  /  ( Point_j_DOWN(1,Need_point_down) * GAIN_BS2D(DUE,CUE) + N0 ) );

Need_RC_down                                  =                              log2( 1+ ( Point_j(1,Need_point_down) * GAIN_C_DOWN(1,CUE) )  /  (  N0 ) );  

R_Q_D                                               =                               log2( 1+ ( Point_j(1,Need_point_down) * GAIN_C_DOWN(1,CUE) )  /  (  N0 ) );  

Solution_down                                   =                              Solution_down - R_CU_DOWN(1,CUE);




%% 如果两者不能形成匹配
if Y0_j > PBS   |  Y0_i >Puser  
    Solution_down                                =                              0;
end

if Solution_down <= 0
    Need_RD_down=0;
     Solution_down = 0;
    Need_RC_down                                  =                              log2( 1+ ( PBS * GAIN_C_DOWN(1,CUE) )  /  (  N0 ) );  
end



%end
