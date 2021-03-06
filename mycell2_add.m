clc;clear
disp('**************  welcome   **************');
%% 第二问元胞自动机仿真测试 升级版(风向 坡度)
%     properties
%         T;loseQ;
%         state;%0表示已燃完；1表示正在燃；2表示还没有开始
%         Qpre;%其实是还差多少能量 小于0表示可以燃了
%         Qall;%其实是还剩下多少能量 小于0表示可以熄火了
%% 初始化
%init
haveEmpty=true;maxEmpty=.25;
R=250;C=250;
QALL=12.4;QPRE=0.63;
T=5;
%wind_grade=[0 0.1 0.2 0.5 0.8]
wind_grade_set=4; 
%单位rad  定义域[0 , pi/2]
slope_theta=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%      GO       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
Map = [128,118,105;
    237,145,33;
    255,99,71;
    255,0,0;
    255,99,71 ;
    255,127,80;
    0 255 0]/255;
colormap(Map);

for i=1:R
    for j=1:C
        info=[2 QPRE QALL , 10  QALL/T];
        arr(i,j)=struct('state',info(1),'Qpre',info(2),'Qall',info(3), ...
            'T',info(4),'loseQ',info(5));
    end
end
%--------------------------干扰测试----------------------------------------%
if haveEmpty
    for i=1:ceil(maxEmpty*R*C)
        tempi=ceil(rand(1).*(R-2))+1;
        tempj=ceil(rand(1)*(C-2))+1;
        arr(tempi,tempj).state=0;
        arr(tempi,tempj).Qpre=0;
        arr(tempi,tempj).Qall=0;
    end
end
%-------------------------------------------------------------------------%
arr(R/2,C/2).state=1;
out=false;Num=0;
arr_=arr;
% T=5;
% loseQ=1;;%每次少的能量
% preQ=1;%每次预热的能量
around=[-1 -1;0 -1;1 -1;
    -1 0;0 0;1 0;
    -1 1;0 1;1 1];
PI=0.0887;PII=0.1613;%两类的比值
losePercent=[PI PII PI , PII 0 PII , PI PII PI];
%% plus  预初始化  
Q1=PI*QALL/T;Q2=PII*QALL/T;Q3=PI*QALL/T;
Q4=PII*QALL/T;Q5=0;        Q6=PII*QALL/T;
Q7=PI*QALL/T;Q8=PII*QALL/T;Q9=PI*QALL/T;
normalQ=[Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9];
%% 风速
wind_grade=[0 0.1 0.2 0.5 0.8]*-1;
Vo=wind_grade(wind_grade_set);
windQ = [(Q1* 1/sqrt(Vo^2+sqrt(2)*Vo+1) + Q4* Vo/ sqrt(1+Vo^2))  ... 
     (Q2 * 1 + Q8 * Vo) ... 
     (Q3* 1/sqrt(Vo^2+sqrt(2)*Vo+1) + Q6* Vo/ sqrt(1+Vo^2))... 
     (Q4* 1/ sqrt(1+Vo^2)) ...
     0 ...
     (Q6* 1/ sqrt(1+Vo^2)) ...
     0 ...
     (Q8*(1-Vo)) ...
     QALL/T ];
 for i=1:8
    windQ(9)=windQ(9)-windQ(i);
 end
 windQ(7)=windQ(9)/2;
 windQ(9)=windQ(7);
if sum(windQ-normalQ) > 0.0001
    error('error windQ!');
end
losePercentByWind=windQ./normalQ;
losePercentByWind(5)=0;

%% 坡度
slope_r=1;%%%%%%%%%%%%%%%%%%%%%%%%    TODO    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Delta_V=0.98*slope_theta*slope_r;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D=(pi*slope_r^2 / 2 + Delta_V) / (pi*slope_r^2 / 2 - Delta_V);
% D=1;
slopeQ=[Q1 ... 
    (Q2 * 2  * D/(D+1)) ... 
    (Q3 * 2 * D/(D+1)) ... 
    (Q4 * 2  * 1/(D+1)) ... 
    0 ... 
    (Q6 * 2  * D/(D+1)) ... 
    (Q7 * 2 * 1/(D+1)) ... 
    (Q8 * 2  * 1/(D+1)) ... 
    Q9];
losePercentBySlop=slopeQ./normalQ/2.718;
losePercentBySlop(5)=0;
%% ready?
loseComplex = losePercent.* losePercentByWind .* losePercentBySlop;

%% GO
disp(sprintf('元胞大小：%d * %d \n部分参数：T=%d \n Qall=%d \n Qpre=%d ', ... 
    R,C,T,QALL,QPRE));
while true
    for i=1:R
        for j=1:C
            if arr(i,j).state==1
                arr_(i,j).Qall=arr_(i,j).Qall-arr_(i,j).loseQ;
                if arr_(i,j).Qall<=0
                    arr_(i,j).state=0;
                end
                
                for k=1:9%周围的扫描一下
                    if i+around(k,1)<=0 || j+around(k,2)<=0 || ...
                            i+around(k,1)>R || j+around(k,2)>C
                        continue;
                    end
%                     if false && arr_(i+around(k,1),j+around(k,2)).state==1%正在烧
%                         arr_(i+around(k,1),j+around(k,2)).Qall = ...
%                             arr_(i+around(k,1),j+around(k,2)).Qall- ...
%                             loseQ;
%                         if arr_(i+around(k,1),j+around(k,2)).Qall<=0
%                             arr_(i+around(k,1),j+around(k,2)).state=0;
%                         end
%                     end
                    if arr_(i+around(k,1),j+around(k,2)).state==2%还没烧
                        if i==1 || j==1 || i==R || j==C
                            continue;
                        end
                        arr_(i+around(k,1),j+around(k,2)).Qpre = ...
                            arr_(i+around(k,1),j+around(k,2)).Qpre- ... 
                            arr_(i,j).loseQ * loseComplex(k);
                        if arr_(i+around(k,1),j+around(k,2)).Qpre<=0
                            arr_(i+around(k,1),j+around(k,2)).state=1;
                        end
                        
                    end
                end
            end
%             cells(i,j)=arr(i,j).state+1;
            cells(i,j)=arr(i,j).Qall;
        end
    end
    arr=arr_;
    %     if arr(1,j).state<=1 || arr(R,j).state<=1 ...
    %             arr(i,1).state<=1 || arr(i,C).state<=1
    %         out = ture;
    %     end
    if out || Num>2333
        break;
    end
    imagesc(cells);
    pause(0.001);Num=Num+1;
    switch Num
        case 12
            liu1=cells;
        case 36
            liu2=cells;
        case 68
            liu3=cells;
        case 98
            liu4=cells;
    end
end
disp('**************  end  **************');
figure
Map = [128,118,105;
    237,145,33;
    255,99,71;
    255,0,0;
    255,99,71 ;
    255,127,80;
    0 255 0]/255;
colormap(Map);
subplot(1,4,1);imagesc(liu1);axis off
subplot(1,4,2);imagesc(liu2);axis off
subplot(1,4,3);imagesc(liu3);axis off
subplot(1,4,4);imagesc(liu4);axis off




