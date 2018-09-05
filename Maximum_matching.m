%% 函数功能：通过使用匈牙利算法，对用户进行子载波分配

clear all

%% 将结果写入 text 文件
% fid0 = fopen('C:\Users\Administrator\Desktop\DOWN500\D=2\AVE_R_D.txt','a');                                                                                                          % 写入 DUE 用户的数据速率之和
% 
% fid1 = fopen('C:\Users\Administrator\Desktop\DOWN500\D=2\AVE_SUM_capacity.txt','a');                                                                                          % 写入 系统总体的数据速率之和


%% 初始化所需的，写入记事本的数值为0
AVE_R_D1                                                  =                         0;                                      
AVE_SUM_capacity1                                  =                         0;    
ratio                                                               =                     0;
sum_sum1  =0;
a=0;
b=0;
C=0;
C2=0;







for loop=1:100                                                                                                                                                                         % 循环 1000 次，取平均值

    
%% 首先声明全局变量， n 是蜂窝用户的个数， t 是D2D用户的个数
global n t 

n                                                                =                          20;                                                                                                                          % 蜂窝用户的个数
t                                                                 =                          20;                                                                                                                          % 定义DUE的个数

%% 调用 GP_method 函数，产生匈牙利算法的二分图匹配的权值
Weight_matrix                                           =                         zeros(t,2*n);
RD                                                             =                         zeros(t,2*n);
RC                                                             =                         zeros(t,2*n);                                    
for DUE=1:t
    for CUE=1:n
        
        [Solution_up,Solution_down,Need_RC_up,Need_RC_down,R_CU_UP,R_CU_DOWN,Need_RD_up,Need_RD_down] = GP_method(CUE, DUE); %进行一对一的匹配，得到匹配后的功率值
        
        Weight_matrix(DUE,CUE*2-1 )             =                        Solution_up;
        %Weight_matrix(DUE,CUE*2 )                =                        Solution_down;      
        RD(DUE,CUE*2-1)                               =                        Need_RD_up;
        %RD(DUE,CUE*2)                                  =                        Need_RD_down;
        RC(DUE,CUE*2-1)                               =                        Need_RC_up;
        %RC(DUE,CUE*2)                                  =                        Need_RC_down;        
    end
end


%% test for Hungarian_Algorithm
% costMat                                                     =                        [5 4 1 2; 3 2 3 2; 3 1 1 5; 4 3 1 2]; 
% Max_value                                                 =                        max(max(costMat));
% costMat                                                     =                        Max_value - costMat;
% [assignment,cost]                                       =                        Hungarian_Algorithm1(costMat);

%% 使用匈牙利算法，获得用户最佳的匹配值
costMat                                                     =                        Weight_matrix;
Max_value                                                 =                        max(max(costMat));
costMat                                                     =                        Max_value - costMat;
[assignment,cost]                                       =                        Hungarian_Algorithm1(costMat);
AAA                                                           =                        assignment;

%% 将匹配结果得到的矩阵，复原得到D2D用户获得数据速率
R_D_sum                                                   =                         0;
for i=1:t
    if AAA(1,i)~=0
        R_D_sum                                               =                         R_D_sum + RD(i,AAA(1,i));
    end
end

ACCESS = 0;
for i=1:t
    if AAA(1,i)~=0
        if RD(i,AAA(1,i)) ~= 0
        	 ACCESS           =     ACCESS +1;
        end
    end
end

% for x=1:t
%      if  AAA(1,x)>2n
%          AAA(1,x)=0;
%      end
% end
%  

 
      
%% R_D_sum 是仿真所需的 DUE 用户的数据速率之和
R_D_sum;

AVE_R_D1                                                  =                         AVE_R_D1 + R_D_sum;
AVE_R_D                                                  =                         AVE_R_D1/10;

%% 将匹配结果得到的值，复原得到
R                                                                =                        zeros(t,2*n);
R_sum                                                        =                        sum(R_CU_UP)+sum(R_CU_DOWN);                                        % 总的数据速率为上行网络和下行网络的数据速率之和


sum_sum1                              =       sum_sum1 +      R_sum;                  

sum_sum                               =         sum_sum1/10;


for DUE=1:t
    for CUE=1:n
        if assignment(1,DUE)==CUE*2-1                                                                                                                                  % 如果DUE复用了蜂窝用户上行链路的子载波
            R( DUE,CUE*2-1)                            =                        1;                                                                                             % 先将匹配之前的数据速率减掉，再加上匹配以后系统获得数据速率                                                                                         
            R_sum                                            =                         R_sum +Weight_matrix(DUE,CUE*2-1)  ;
            a=Weight_matrix(DUE,CUE*2-1);
        end
        if assignment(1,DUE)==CUE*2                                                                                                                                     % 如果DUE复用了蜂窝用户下行链路的子载波                          
            R( DUE,CUE)                                   =                        1;     
            R_sum                                            =                         R_sum +Weight_matrix(DUE,CUE)  ;  
            b=Weight_matrix(DUE,CUE);
        end
    end
end

for i=1:t
    a=Weight_matrix(i,assignment(1,i));
   C=C+a;
end


C1=C/10;


need=sum_sum+C1;


for i=1:t
    b=RD(i,assignment(1,i));
   C2=C2+b;
end

DD=C2/100

%% R_sum 就是仿真所需的 系统的数据速率之和




R_sum;

AVE_SUM_capacity1                                      =                      AVE_SUM_capacity1 +  R_sum;
AVE_SUM_capacity                                      =                      AVE_SUM_capacity1/10;


ratio1                                                             =                    ACCESS/t;
ratio                                                               =                    ratio+ratio1 ;
%ratio                                                               =                    ratio/100 


end



% fprintf (fid0,'%f\n',AVE_R_D);
% fclose (fid0) ;
% 
% fprintf (fid1,'%f\n',AVE_SUM_capacity);
% fclose (fid1) ;














