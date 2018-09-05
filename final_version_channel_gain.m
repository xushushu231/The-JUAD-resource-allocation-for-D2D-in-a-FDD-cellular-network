function [GAIN_C_UP,GAIN_C_DOWN,GAIN_D2BS,GAIN_BS2D,GAIN_D_UP,GAIN_D_DOWN,GAIN_C2D,GAIN_D2C]  =  final_version_channel_gain()

%代码功能：根据信道模型来计算信道增益
%输入参数：由Scenerio位置信息产生的距离信息
%输出参数：所需的各种信道增益

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   TEST_ final_version：2018-05-23   逐行检查无误，数据均正确
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GAIN_C2D        ::     二维矩阵   ：：  (蜂窝C,在载波K上)                           
% GAIN_D2BS      ::     二维矩阵   ：：  (组播组D,在载波K上)
% GAIN_D            ::     三维矩阵   ：：  (组播组D中,对接收端L，在载波K上)              
% GAIN_C2D        ::     四维矩阵   ：：  (蜂窝C，对组播组Di中，接收端L，在载波K上)      

global n t num_mlti K 

[DIS_C2D,DIS_Di2Dj,DIS_D,DIS_D2BS,DIS_C2BS] = final_version_Scenario()   ;                                                     % 调用scenario函数，生成所需用户之间的距离

%% 利用距离DIS_C2BS，生成蜂窝用户到基站的信道增益，我们已经假定蜂窝用户已经预先分配过信道
GAIN_C2BS                           =                            zeros(n,K);                                                                                % n×K的矩阵，每个蜂窝用户在每个子载波上面的信道增益
G1                                         =                            10^(-2);                                                                                   % path loss constant
alpha1                                   =                            3;                                                                                             % path loss exponent 
for j=1:n
    beta1                                 =                            exprnd(1,1,K);                                                                           % 快衰落 服从均值为1的指数分布 
    gamma1                            =                            lognrnd(0,10^(0.8),1,K);                                                            % 慢衰落 服从标准差为8dB的对数正态分布  
    GAIN_C2BS(j,:)                   =                            G1*(beta1.*(gamma1)*DIS_C2BS(1,j)^(-alpha1));
end
for j=1:n
    for k=1:K
        if  GAIN_C2BS(j,k)>1e-4
            GAIN_C2BS(j,k)          =                            1e-8 + (9e-12-1e-12).*rand(1);
        end
    end
end
% for j=1:n
%     for k=1:K
%         if  GAIN_C2BS(j,k)<1e-11
%             GAIN_C2BS(j,k)          =                            1e-11 + (9e-12-1e-12).*rand(1);
%         end
%     end
% end

GAIN_C_UP                           =                             GAIN_C2BS(1,:);
GAIN_C_DOWN                    =                             GAIN_C2BS(2,:);

%% 利用距离DIS_D2BS，生成组播组簇头，即基站到D2D用户的干扰的信道增益
GAIN_BS2D                           =                            zeros(t,K);                                                                                 % t×K的矩阵，每个组播组发送端到基站的信道增益
G2                                         =                            10^(-2);                                                                                   % path loss constant
alpha2                                   =                            3;                                                                                             % path loss exponent 
beta2                                    =                             exprnd(1,K,t);                                                                           % 快衰落 服从均值为1的指数分布 
gamma2                               =                             lognrnd(0,10^(0.8),K,t);                                                            % 慢衰落 服从标准差为8dB的对数正态分布  
NEWDIS_D2BS                     =                             repmat(DIS_D2BS, K , 1 );
GAIN_BS2D                          =                             G2*(beta2.*(gamma2.*NEWDIS_D2BS.^(-alpha2)))';




%% 利用距离DIS_D2BS，生成组播组簇头，即组播组发送端对基站造成的干扰
GAIN_D2BS                           =                            zeros(t,K);                                                                                 % t×K的矩阵，每个组播组发送端到基站的信道增益
G2                                         =                            10^(-2);                                                                                   % path loss constant
alpha2                                   =                            3;                                                                                             % path loss exponent 
beta2                                     =                            exprnd(1,K,t);                                                                           % 快衰落 服从均值为1的指数分布 
gamma2                                =                            lognrnd(0,10^(0.8),K,t);                                                            % 慢衰落 服从标准差为8dB的对数正态分布  
NEWDIS_D2BS                      =                            repmat(DIS_D2BS, K , 1 );
GAIN_D2BS                           =                            G2*(beta2.*(gamma2.*NEWDIS_D2BS.^(-alpha2)))';


%% 利用距离DIS_D，生成组播组内部，发送端到接收端之间的距离，通信的近距离效应，就是得益于这个信道增益
G3                                          =                           10^(-2);                                                                                    % path loss constant
alpha3                                    =                            3;                                                                                             % path loss exponent 
beta3                                      =                           exprnd(1,t,max(num_mlti),K);                                                     % 快衰落 服从均值为1的指数分布 
max(num_mlti);
gamma3                                 =                           lognrnd(0,10^(0.8),t,max(num_mlti),K);                                      % 慢衰落 服从标准差为8dB的对数正态分布  
GAIN_Dindex                          =                           G3*beta3.*gamma3;
D_alpha                                   =                          DIS_D.^(-alpha3);
%D_alpha(D_alpha==inf)         =                          0;
for Y=1:t
    for X=1:max(num_mlti)
        for k=1:K
        GAIN_D_UP(Y,X,k)=GAIN_Dindex(Y,X,k)*D_alpha(Y,X);
        end
    end
end

%% 利用距离DIS_D，生成组播组内部，发送端到接收端之间的距离，通信的近距离效应，就是得益于这个信道增益
G3                                          =                           10^(-2);                                                                                    % path loss constant
alpha3                                    =                            3;                                                                                             % path loss exponent 
beta3                                      =                           exprnd(1,t,max(num_mlti),K);                                                     % 快衰落 服从均值为1的指数分布 
max(num_mlti);
gamma3                                 =                           lognrnd(0,10^(0.8),t,max(num_mlti),K);                                      % 慢衰落 服从标准差为8dB的对数正态分布  
GAIN_Dindex                          =                           G3*beta3.*gamma3;
D_alpha                                   =                          DIS_D.^(-alpha3);
%D_alpha(D_alpha==inf)         =                          0;
for Y=1:t
    for X=1:max(num_mlti)
        for k=1:K
        GAIN_D_DOWN(Y,X,k)=GAIN_Dindex(Y,X,k)*D_alpha(Y,X);
        end
    end
end


%% 利用距离DIS_C2D,生成蜂窝用户对D2D接收端干扰的信道增益，DIS_C2D是三维矩阵，表示蜂窝用户到组播组接收端的距离
G5                                          =                           10^(-2);                                                                                    % path loss constant
alpha5                                    =                           3;                                                                                              % path loss exponent 
beta5                                      =                           exprnd(1,n,t);                                                  % 快衰落 服从均值为1的指数分布 
gamma5                                 =                           lognrnd(0,10^(0.8),n,t);                                   % 慢衰落 服从标准差为8dB的对数正态分布 
GAIN_C2D_index                    =                           G5*(beta5.*gamma5);
GAIN_C2D(:,:)                         =                           GAIN_C2D_index(:,:).*(DIS_C2D.^(-alpha5));


G6                                          =                           10^(-2);  
alpha6                                    =                           3;  
beta6                                      =                           exprnd(1,n,t);                                                  % 快衰落 服从均值为1的指数分布 
gamma6                                 =                           lognrnd(0,10^(0.8),n,t);                                   % 慢衰落 服从标准差为8dB的对数正态分布 
GAIN_D2C_index                    =                           G6*(beta6.*gamma6);
GAIN_D2C(:,:)                         =                           GAIN_D2C_index(:,:).*(DIS_C2D.^(-alpha6));
%end

