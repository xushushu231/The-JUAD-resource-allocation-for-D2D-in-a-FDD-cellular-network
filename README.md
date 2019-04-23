# Joint Uplink and Downlink Resource Allocation for D2D Communications Underlying Cellular Networks

Paper From：https://ieeexplore.ieee.org/document/8555896

@INPROCEEDINGS{8555896, 
author={C. {Kai} and L. {Xu} and J. {Zhang} and M. {Peng}}, 
booktitle={2018 10th International Conference on Wireless Communications and Signal Processing (WCSP)}, 
title={Joint Uplink and Downlink Resource Allocation for D2D Communication Underlying Cellular Networks}, 
year={2018}, 
volume={}, 
number={}, 
pages={1-6}, 
doi={10.1109/WCSP.2018.8555896}, 
ISSN={2472-7628}, 
month={Oct.},}
************************************************************************************************************

scenario            是系统场景子函数，包括基站位置，用户位置的随机生成
channel gain        是信道增益子函数，使用场景里生成的位置信息，根据信道增益模型，得出不同用户之间的信道增益
Hungarian           是匈牙利算法的代码，这是别人已经封装好的代码，直接拿来就可以使用，不需要任何更改
GP_method           是使用CVX工具箱，来解功控，但是CVX耗时较多，所以没采用这种解法，采用了本文提出的遍历法
power               是本文提出的遍历法解决功控问题
matching            是main函数，调用各个子函数，得到不同的结果
