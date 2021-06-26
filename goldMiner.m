function goldMiner
Mainfig=figure('units','pixels','position',[50 100 750 500],...
                       'Numbertitle','off','menubar','none','resize','off',...
                       'name','goldMiner');
axes('parent',Mainfig,'position',[0 0 1 1],...
   'XLim', [0 750],...
   'YLim', [0 500],...
   'NextPlot','add',...
   'layer','bottom',...
   'Visible','on',...
   'YDir','reverse',...
   'XTick',[], ...
   'YTick',[]);

bkgPic=imread('.\pic\bkg.png');
image([0,750],[0,500],bkgPic)

[manPic,~,manAlp]=imread('.\pic\man.png');
image([400-60,400+60],[49.5-45,49.5+45],manPic,'AlphaData',manAlp)

[clawPic,~,clawAlp]=imread('.\Pic\claw.png');
clawPic=double(clawPic)./255;
clawPicR=clawPic(:,:,1);
clawPicG=clawPic(:,:,2);
clawPicB=clawPic(:,:,3);
clawPicR(clawAlp<1)=nan;
clawPicG(clawAlp<1)=nan;
clawPicB(clawAlp<1)=nan;
clawPic(:,:,1)=clawPicR;
clawPic(:,:,2)=clawPicG;
clawPic(:,:,3)=clawPicB;

clawPos=[380,75];
ropePos=[380,75];

[xgrid,ygrid]=meshgrid((1:size(clawAlp,2))./2,(1:size(clawAlp,1))./2);
xgrid=xgrid-size(clawAlp,2)/4;

thetaList=linspace(-2*pi/5,2*pi/5,50);
thetaIndex=1;
theta=thetaList(thetaIndex);v=0;
dir=1;grabbing=false;

cost=cos(theta);
sint=sin(theta);
rotateX=cost.*xgrid+sint.*ygrid;
rotateY=cost.*ygrid-sint.*xgrid;

drawClawHdl=surface(rotateX+clawPos(1),rotateY+clawPos(2),...
            zeros(size(clawAlp)),clawPic,...
            'EdgeColor','none');
drawLineHdl=plot([clawPos(1),ropePos(1)],[clawPos(2),ropePos(2)],'k','LineWidth',2);
%stone part======================================================
stoneName={'gold','gold','stone1','stone2','diamond'};
stonePic{length(stoneName)}=[];
stoneAlp{length(stoneName)}=[];
for i=1:length(stoneName)
    [C,~,Alp]=imread(['.\pic\',stoneName{i},'.png']);
    stonePic{i}=C;
    stoneAlp{i}=Alp;
end
stoneV=[-2,-3,-3,-3,-5];
stonePrice=[800,500,200,100,1000];
stoneSize=[50,50;30,30;24,20;15,12;8,8];


stonePos=[200,300;400,350;500,200;50,240;50,300;
          700,420;170,180];
stoneType=[1,2,3,4,5,1,2];
stoneTag=1:length(stoneType);
stoneXrange=[stonePos(:,1)-stoneSize(stoneType',1),stonePos(:,1)+stoneSize(stoneType',1)];
stoneYrange=[stonePos(:,2)-stoneSize(stoneType',2),stonePos(:,2)+stoneSize(stoneType',2)];

for i=1:length(stoneTag)
    drawStone(stonePos(i,:),stoneType(i),stoneTag(i))   
end

    function drawStone(pos,i,j)
        image([-stoneSize(i,1),stoneSize(i,1)]+pos(1),...
              [-stoneSize(i,2),stoneSize(i,2)]+pos(2),...
              stonePic{i},...
              'AlphaData',stoneAlp{i},...
              'UserData',j)  
    end

holdOnType=0;
drawHoldOnHdl=image([0,1],[0,1],ones(1,1),'AlphaData',zeros(1,1));

text(10,40,'Money:','FontSize',20,'Color',[1 1 1],'FontName','Cambria','FontWeight','bold')
money=0;
moneyStrHdl=text(110,40,'$0','FontSize',20,'Color',[0.5137 0.7882 0.2157],'FontName','Cambria','FontWeight','bold');

%==========================================================================    
set(gcf, 'KeyPressFcn', @key)
fps=20;
game=timer('ExecutionMode', 'FixedRate', 'Period',1/fps, 'TimerFcn', @minergame);
start(game)

    function minergame(~,~)
        if ~grabbing
            switch 1
                case thetaIndex==1,dir=1;
                case thetaIndex==50,dir=-1;
            end
            thetaIndex=thetaIndex+dir;
            theta=thetaList(thetaIndex);
            cost=cos(theta);
            sint=sin(theta);
            rotateX=cost.*xgrid+sint.*ygrid;
            rotateY=cost.*ygrid-sint.*xgrid;
        else
            cost=cos(theta);
            sint=sin(theta);
            clawPos=clawPos+[sint,cost].*v;
            
            n=touchThing(clawPos+5.*[sint,cost]);
            if n==-1
                v=-abs(v);
            elseif n>0
                delete(findobj('UserData',stoneTag(n)));
                v=stoneV(stoneType(n));
                holdOnType=stoneType(n);
                stonePos(n,:)=[];
                stoneType(n)=[];
                stoneTag(n)=[];
                stoneXrange(n,:)=[];
                stoneYrange(n,:)=[];
                set(drawHoldOnHdl,...
                    'XData',[-stoneSize(holdOnType,1),stoneSize(holdOnType,1)]+clawPos(1)+norm(stoneSize(holdOnType,:))*sint,...
                    'YData',[-stoneSize(holdOnType,2),stoneSize(holdOnType,2)]+clawPos(2)+norm(stoneSize(holdOnType,:))*cost,...
                    'CData',stonePic{holdOnType},'AlphaData',stoneAlp{holdOnType});
            end  
            
            if clawPos(2)<=ropePos(2)
                clawPos=ropePos;
                grabbing=false;
                if holdOnType>0
                    money=money+stonePrice(holdOnType);
                    set(moneyStrHdl,'String',['$',num2str(money)])
                end
                holdOnType=0;
                set(drawHoldOnHdl,'XData',[0,1],...
                                  'YData',[0,1],...
                                  'CData',ones(1,1),...
                                  'AlphaData',zeros(1,1));                  
            end
            if holdOnType~=0
                set(drawHoldOnHdl,...
                    'XData',[-stoneSize(holdOnType,1),stoneSize(holdOnType,1)]+clawPos(1)+norm(stoneSize(holdOnType,:))*sint,...
                    'YData',[-stoneSize(holdOnType,2),stoneSize(holdOnType,2)]+clawPos(2)+norm(stoneSize(holdOnType,:))*cost);
            end
        end
        
        
        set(drawClawHdl,'XData',rotateX+clawPos(1),'YData',rotateY+clawPos(2));
        set(drawLineHdl,'XData',[clawPos(1),ropePos(1)],'YData',[clawPos(2),ropePos(2)]);
    end

    function n=touchThing(clawPos)
        n=0;
        if clawPos(1)<20||clawPos(1)>730||clawPos(2)>480
            n=-1;     
        end
        flagX=clawPos(1)>=stoneXrange(:,1)&clawPos(1)<=stoneXrange(:,2);
        flagY=clawPos(2)>=stoneYrange(:,1)&clawPos(2)<=stoneYrange(:,2);
        flagXY=flagX&flagY;
        if any(flagXY)
            n=find(flagXY);
        end
    end

    function key(~,event)
        switch event.Key
            case 'downarrow'
                grabbing=true;v=4;
        end
    end
end