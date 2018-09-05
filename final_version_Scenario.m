function [DIS_C2D,DIS_Di2Dj,DIS_D,DIS_D2BS,DIS_C2BS] = final_version_Scenario()
 
%代码功能  ：   随机产生用户的地理位置信息，并求出所需的各种距离信息
%输入参数  ：   n-蜂窝用户个数
%                     t-D2D组播组的个数
%输出参数  ：   所需用户之间的距离，用来计算信道增益

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   TEST_final_version：2018-04-08   逐行检查无误，数据均正确
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DIS_C2D          ::     二维矩阵   ：：  (C→BS)                           
% DIS_D2BS        ::     二维矩阵   ：：  (D→BS)
% DIS_D              ::     二维矩阵   ：：  (D→l)              
% DIS_Di2Dj        ::     三维矩阵   ：：  (Di→Dj→l)   
% DIS_C2D          ::     三维矩阵   ：：  (C→D→l)  

global n t num_mlti K Rreqj 

% cla reset

%%  以下参数是需要在仿真实验中可能改动的参数，特分离出来，以备后续改变****************************************************************************************************

%************************ 用户个数信息*******************************************
n                          =                          20;                          %蜂窝用户的个数
Rreqj                    =                          6* ones(n,1);          % 蜂窝用户所需的最低的数据速率需求
t                           =                          20;                          %定义D2D组播组的个数
K                           =                          20;

%num_mlti              =                          [3,3,4,4,5];                  %每一个D2D组播组内，有几个D2D receiver，这里默认每个组拥有四个接收用户
num_mlti            =                           1*ones(1,t);




%************************ 用户距离信息*******************************************
r                           =                           500;                             % 基站的半径
r_DG                     =                           5;                              % 这是D2D组播组的，半径，需要注意的是，这是两个直角边的长度
%**********************************************************************************

%% ***********************************************************************************************************************************************************************

x                           =                           2*r*rand(1,n)-r;             %随机生成x的坐标
y                           =                           2*r*rand(1,n)-r;             %随机生成y的坐标
location                    =                           x.^2+y.^2;
index1                      =                           find(location>r.^2);         %根据勾股定理，找到（不！合适）的x，y值，即用户的位置，在基站外的点
len1                        =                           length(index1) ;             %矩阵index1的维数
x(index1)                   =                           [];                          %将随机产生的基站外的点，置空
y(index1)                   =                           [];
while len1                                                                           %如果len不为0，即存在不符合条件的点，需要重新生成新的点
    xt                      =                           2*r*rand(1,len1)-r;          %len就是缺少点的个数，重新生成缺少的点即可
    yt                      =                           2*r*rand(1,len1)-r;
    index2                  =                           find(xt.^2+yt.^2>r.^2);
    len1                    =                           length(index2);
    xt(index2)              =                           [];
    yt(index2)              =                           [];
    x                       =                           [x xt];                      %把新的满足条件的点放进数组里面
    y                       =                           [y yt];
end
x;                                                                                   %蜂窝用户坐标位置的x值
y;                                                                                   %蜂窝用户坐标位置的y值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%生成D2D组播组的位置%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dx                          =                            2*r*rand(1,t)-r;            %D2D用户发送端坐标位置的x值
dy                          =                            2*r*rand(1,t)-r;
index3                      =                            find(dx.^2+dy.^2>r.^2);
len2                        =                            length(index3);
dx(index3)                  =                            [];
dy(index3)                  =                            [];
while len2
    xt                      =                            2*r*rand(1,len2)-r;
    yt                      =                            2*r*rand(1,len2)-r;
    index4                  =                            find(xt.^2+yt.^2>r.^2);
    len2                    =                            length(index4);
    xt(index4)              =                            [];
    yt(index4)              =                            [];
    dx                      =                            [dx xt];
    dy                      =                            [dy yt];
end

%TODO:每个组拥有接收用户的个数是不同的，8,10,6,6,大致如上
%围绕着每一个发送端，拥有不同数目的接收端，即组播组内用户的个数是不相同的，【4,5,6,7】
alternate_t                 =                            t; 
linkdx                      =                            zeros(t,max(num_mlti));
linkdy                      =                            zeros(t,max(num_mlti));
for group=1:t
    new_linkdx              =                            dx(group)+r_DG*2^0.5*ones(1,num_mlti(group));
    new_linkdy              =                            dy(group)+r_DG*2^0.5*ones(1,num_mlti(group)); 
    for userl=1:num_mlti(group)
        linkdx(group,userl)      =                           new_linkdx(1,userl);
        linkdy(group,userl)      =                           new_linkdy(1,userl);
    end
end
 linkdx;
 linkdy;
%%%%%%%%%%%%%%%%%%%%%%%%%%下面是画图内容，生成Fig.1，即通信系统场景图%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x0                          =                            0;                          %画出圆形区域的边框
y0                          =                            0;
r                           =                            500;
theta                       =                            0:pi/50:2*pi;
x1                          =                            x0+r*cos(theta);
y1                          =                            y0+r*sin(theta);

%  画图程序
% plot(x0,y0,'sk',x,y,'v')
% hold on  
% for group=1:t
%     plot(dx(group),dy(group),'r*')
%     hold on 
%     for num=1:num_mlti(group)
%         plot(linkdx(group,num),linkdy(group,num),'*r')  
%         hold on 
%     end
% end
% plot(x1,y1,'-k')
% hold on
% legend('BS','CU','DTx','DRx');
% axis equal

%%%%%%%%%%%%%%%%%%%%%%%%%%下面计算用户之间的距离，生成信道增益的模型%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DIS_C2D                      =                            [];                         %三维矩阵，表示蜂窝用户到每个D2D组播组的每一个接收端的位置，用来计算蜂窝用户对组播接受用户的干扰
DIS_Di2Dj                    =                            [];                         %二维矩阵，表示D2D组播组发送端到其他组播组接收端的距离，用来计算D2D组播组之间互相的干扰 
DIS_D                          =                            [];                         %二维矩阵，表示D2D组播组内，发送端到接收端的距离信息，用来计算D2D通信的近距离效应带来的信道增益
DIS_D2BS                    =                            [];                         %二维矩阵，表示每一个D2D组播组的发送端对到基站的距离，用来计算D2D对上行蜂窝用户的干扰
DIS_C2BS                    =                            [];                         %二维矩阵，表示每个蜂窝用户，到基站的位置，用来生成蜂窝用户的信道增益

%sym cindex;                                                                         % 表示cellular user
%sym dindex;                                                                         % 表示D2D group
%sym lindex;                                                                          % 表示l user in D2D group  
for cindex=1:n 
    for dindex=1:t
        for lindex=1:num_mlti(dindex)
            DIS_C2D(cindex,dindex,lindex)    = sqrt(  (x(1,cindex)-linkdx(dindex,lindex))^2 + (y(1,cindex)-linkdy(dindex,lindex))^2   );
        end
    end
end
%size(DIS_C2D)                                                                        % 测试矩阵大小                                                            
%D=DIS_C2D(1,5,:)                                                                  % 测试矩阵数据是为理想数据

%sym igroup                                                                            % 第i个D2D组播组
%sym jgroup                                                                            % 第j个组播组
%sym luser                                                                               % 第j个组播组中的第l个用户                       
for igroup=1:t
    for jgroup=1:t
        for luser=1:num_mlti(jgroup)
            DIS_Di2Dj(igroup,jgroup,luser)   = sqrt(  (dx(1,igroup)-linkdx(jgroup,luser))^2 +  (dy(1,igroup)-linkdy(jgroup,luser))^2  );
        end
    end
end
%size(DIS_Di2Dj)                                                                        % 测试矩阵大小                                                            
%D=DIS_Di2Dj(3,3,:)                                                                  % 测试矩阵数据是为理想数据

%sym igroup                                                                              % 第i个D2D组播组
%sym luser                                                                                 % 第j个组播组中的第l个用户                 
for igroup=1:t
    for luser=1:num_mlti(igroup)
        DIS_D(igroup,luser)                 =  sqrt( (dx(1,igroup)-linkdx(igroup,luser))^2 +  (dy(1,igroup)-linkdy(igroup,luser))^2  );
    end
end
%size(DIS_D)                                                                               % 测试矩阵大小                                                            
%D=DIS_D(5,:)                                                                            % 测试矩阵数据是为理想数据

for igroup=1:t
    DIS_D2BS(1,igroup)                      =   sqrt( dx(1,igroup)^2   +   dy(1,igroup)^2     );
end
%DIS_D2BS                                                                            %测试矩阵数据是为理想数据

for cindex=1:n
    DIS_C2BS(1,cindex)                      =   sqrt(  x(1,cindex)^2   +    y(1,cindex)^2     );
end
%DIS_C2BS                                                                            %测试矩阵数据是为理想数据




