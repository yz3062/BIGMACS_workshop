inputFile = 'CycloAstro_demo';

inputMode = 'age_model_construction';
% inputMode = 'stack_construction';

% printFig = 'show';
printFig = 'hide';

% BIGMACS(inputFile,inputMode,printFig);
BIGMACS(inputFile,inputMode);

%% load output data
% add folder to search path
addpath('./Outputs/CycloAstro_demo_d18O')

% load results.mat file
% the 'summary' structure contains most of the output data that will be of interest
load('results.mat');

% remove NaNs from the d18O column and corresponding rows for all fields
for i=1:length(summary)
    NaNrows=isnan(summary(i).d18O);
    fields=fieldnames(summary(i));
    size_d18O=size(summary(i).d18O,1);
    for j=1:numel(fields)
        if size(summary(i).(fields{j}),1)==size_d18O
            summary(i).(fields{j})(NaNrows,:)=[];
        end
    end
    NaNties=isnan(summary(i).additional_ages(:,1));
    summary(i).additional_ages(NaNties,:)=[];
end

% clean up workspace
clear fields i j NaNrows NaNties size_d18O

%% plot the new d18O alignment vs the target record
figure(1)
% specify figure window size and subplot position
set(gcf,'Position',[100,100,1200,600])

% SUBPLOT COMPARING BIGMACS OUTPUT TO THE ALIGNMENT TARGET
subplot('Position',[0.1,0.425,0.8,0.525])
hold on
% plot alignment target
p1=plot(target.stack(:,1),target.stack(:,2),'-','Color',[0 0.4470 0.7410],'LineWidth',1);
% plot median age model from BIGMACS run
p2=plot(summary(1).median,summary(1).d18O,'-','Color',[0.6350 0.0780 0.1840],'LineWidth',1);
hold off
% reverse y axis direction for plotting benthic d18O
axis ij
% set x limits and assign x labels (ages are in kyr, but x labels are displayed in Myr)
xlim([15150 15825])
xticks([15200:100:15800])
xticklabels({'15.2','15.3','15.4','15.5','15.6','15.7','15.8'})
% custom font sizes and ticks for current axes
set(gca,'FontSize',12,'XMinorTick','on','YMinorTick','on')
% assign axis labels
ylabel('\delta^{18}O_{benthic} (‰)','FontSize',14,'FontWeight','bold')
% add legend and title
legend([p2 p1],'Site U1337','Alignment target (Site U1338)','location','northwest','box','off','FontSize',12)
title('Site U1337 vs. alignment target','FontSize',16)


% calculate sedimentation rate of input data
sed_rate=diff(summary.depth)./diff(summary.median)*100;

% SUBPLOT SHOWING SEDIMENTATION RATE OF MEDIAN AGE MODEL
subplot('Position', [0.1,0.1,0.8,0.25])
plot(summary.median(1:end-1),sed_rate,'--','Color',[0.6350 0.0780 0.1840],'LineWidth',1)
% set x limits and assign x labels (ages are in kyr, but x labels are displayed in Myr)
xlim([15150 15825])
xticks([15200:100:15800])
xticklabels({'15.2','15.3','15.4','15.5','15.6','15.7','15.8'})
ylim([0 8])
% custom font sizes and ticks for current axes
set(gca,'FontSize',12,'XMinorTick','on','YMinorTick','on','box','off')
% assign axis labels
xlabel('Age (Myr)','FontSize',14,'FontWeight','bold')
ylabel('Sed. rate (cm/kyr)','FontSize',14,'FontWeight','bold')

clear p1 p2

%% plot the new age model with 95% CIs and tie points
figure(2)
% specify figure window size and subplot position
set(gcf,'Position',[100,100,900,600])
% SUBPLOT FOR OUTPUT AGE MODEL
subplot('Position',[0.1,0.125,0.55,0.8])
hold on
% shade 95% confidence limits for age
fill([summary.lower_95;flip(summary.upper_95)],[summary.depth;flip(summary.depth)],'k','EdgeColor','none',...
    'FaceAlpha','0.25')
% plot age-depth model
plot(summary.median,summary.depth,'--k','LineWidth',1)
hold off
% set x and y axis limits and tick marks
xlim([15150 15825])
xticks([15200:100:15800])
xticklabels({'15.2','15.3','15.4','15.5','15.6','15.7','15.8'})
ylim tight
% custom font sizes and ticks for current axes
set(gca,'FontSize',12,'XMinorTick','on','YMinorTick','on')
% assign axis labels and title
xlabel('Age (Myr)','FontSize',14,'FontWeight','bold')
ylabel('Depth (m)','FontSize',14,'FontWeight','bold')
title('Site U1337 median age model','FontSize',16,'FontWeight','bold')


% SUBPLOT FOR AGE MODEL CONFIDENCE LIMIT WIDTH
subplot('Position',[0.75,0.125,0.2,0.8])
hold on
% shade 95% confidence limits
fill([summary.lower_95-summary.median;flip(summary.upper_95-summary.median)],...
    [summary.depth;flip(summary.depth)],...
    'k','EdgeColor','none','FaceAlpha',0.15)
xline(0,'--k','LineWidth',1)
hold off
xlim([-30 30])
ylim tight
set(gca,'FontSize',12,'XMinorTick','on','YMinorTick','on')
% assign axis labels and title
xlabel('Relative age (kyr)','FontSize',14,'FontWeight','bold')
ylabel('Depth (m)','FontSize',14,'FontWeight','bold')
title('95% CI','FontSize',16,'FontWeight','bold')

figure(3)
subplot(211)
plot(summary.depth,summary.d18O), axis ij
xlabel('depth'), legend('data to be aligned')
subplot(212)
plot(target.stack(:,1),target.stack(:,2),'r'), axis ij
xlabel('age'), legend('target')
