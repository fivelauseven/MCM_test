clc;clear
R=10;
C=10;
myAround=[-.5 -sqrt(3)/2;
    .5 -sqrt(3)/2;
    1 0;
    .5 sqrt(3)/2;
    -.5 sqrt(3)/2;
    -1 0];
figure
for i=5:16
    for j=5:16
        add=0;
        if mod(j,2)==0
%             add=sqrt(3)/2;
        end
        if mod(i,2)==0
            add=add+sqrt(3)/2;
        end
        I=3/2*(i-R/2);J=sqrt(3)*(j-C/2);
        color=[.5 .5 .5];
        if [i,j]==[9 9]
            color=[1 1 1];
        end
        if [i,j]==[10 9]
            color=[0 0 1];
        end
        if [i,j]==[10 8]
            color=[0 1 0];
        end
        if [i,j]==[9 8]
            color=[0 0 0];
        end
        patch(myAround(:,1)'+I,myAround(:,2)'+J+add,color);
    end
end
% axis([-20 20 -20 20])