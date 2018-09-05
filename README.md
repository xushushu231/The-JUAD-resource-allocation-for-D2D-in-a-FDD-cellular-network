# Joint Uplink and Downlink Resource Allocation for D2D Communications Underlying Cellular Networks
WCSP 会议论文源码：Joint Uplink and Downlink Resource Allocation for D2D Communications Underlying Cellular Networks
这是我研究生以来，自己独立完成的第三个小论文，主要是有别于以往研究或分配上行载波资源或分配下行载波资源，提出给联合上下行子载波对用户进行资源分配。主要宗旨就是证明：1+1>2。

%% 下面是代码解释

scenario            是系统场景子函数，包括基站位置，用户位置的随机生成
channel gain        是信道增益子函数，使用场景里生成的位置信息，根据信道增益模型，得出不同用户之间的信道增益
Hungarian           是匈牙利算法的代码，这是别人已经封装好的代码，直接拿来就可以使用，不需要任何更改
GP_method           是使用CVX工具箱，来解功控，但是CVX耗时较多，所以没采用这种解法，采用了本文提出的遍历法，速度相当较快
power               是本文提出的遍历法解决功控问题
matching            是main函数，调用各个子函数，得到不同的结果

对比实验分析，本文可以和Only uplink和Only downlink 进行对比，联合上下行资源进行分配，没有比较趁手的对比方案。
