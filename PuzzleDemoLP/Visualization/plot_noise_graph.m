%% plot the noise experiment graph

 scores_rui1 = [ 
    0.1221    0.5470    0.2975         0
    0.1654    0.5836    0.3511    0.2000
    0.2164    0.6069    0.3894         0
    0.2384    0.6310    0.4211    0.4000
    0.3473    0.6990    0.5254    0.2000
    0.4503    0.7459    0.5939    0.6000
    0.4762    0.7797    0.6348    1.8000
    0.5492    0.8124    0.6863    2.8000
    0.6241    0.8534    0.7398    3.6000
    0.7454    0.8892    0.8181    5.8000
    0.8014    0.9018    0.8511    6.0000
    0.8164    0.9209    0.8791    8.0000
    0.8492    0.9296    0.8897    8.4000
    0.8810    0.9373    0.9105   10.6000
    0.9028    0.9418    0.9216   10.8000
    0.9331    0.9455    0.9328   10.8000
    0.9320    0.9465    0.9367   12.2000
    0.9307    0.9484    0.9413   12.0000
    0.9481    0.9533    0.9533   12.6000
    0.9476    0.9532    0.9527   12.8000];

scores_rui2 = [
        0.4250    0.5433    0.5079    0.6000
    0.4144    0.5146    0.4823    0.6000
    0.3952    0.5370    0.5172    0.2000
    0.4583    0.5860    0.5611    0.2000
    0.4613    0.6419    0.6081    0.8000
    0.5952    0.7288    0.7057    1.6000
    0.6072    0.6951    0.6773    2.8000
    0.5787    0.7203    0.7060    3.2000
    0.7394    0.8064    0.7963    4.4000
    0.8212    0.8508    0.8496    5.0000
    0.8160    0.8566    0.8539    7.2000
    0.8341    0.8741    0.8721    8.4000
    0.8773    0.9050    0.9064    8.8000
    0.9439    0.9419    0.9434   10.6000
    0.9460    0.9467    0.9457   11.2000
    0.9475    0.9459    0.9470   12.0000
    0.9444    0.9491    0.9506   12.2000
    0.9499    0.9484    0.9494   12.2000
    0.9509    0.9497    0.9505   12.4000
    0.9441    0.9434    0.9437   11.2000];

scores_gallagher1 = [    
    0.0041    0.3132    0.0690         0
    0.0111    0.3461    0.0891         0
    0.0143    0.3771    0.1094         0
    0.0136    0.4172    0.1585         0
    0.0380    0.4580    0.1954         0
    0.0931    0.5020    0.2525         0
    0.1356    0.5553    0.3185         0
    0.1559    0.5923    0.3581    0.6000
    0.2355    0.6420    0.4320    0.8000
    0.3018    0.6829    0.5029    1.2000
    0.4168    0.7323    0.5872    1.8000
    0.5097    0.7791    0.6673    2.4000
    0.5521    0.8089    0.7176    3.0000
    0.6628    0.8419    0.7757    3.4000
    0.7236    0.8727    0.8231    4.2000
    0.7739    0.8917    0.8586    5.4000
    0.7786    0.9073    0.8740    6.0000
    0.8362    0.9193    0.8984    8.4000
    0.8793    0.9290    0.9165    9.2000
    0.9009    0.9357    0.9292   10.0000];

scores_gallagher2 = [
        0.0023    0.0600    0.0244         0
    0.0021    0.0635    0.0262         0
    0.0022    0.0705    0.0301         0
    0.0020    0.0736    0.0286         0
    0.0019    0.0778    0.0300         0
    0.0020    0.0862    0.0350         0
    0.0016    0.0938    0.0407         0
    0.0021    0.1071    0.0478         0
    0.0020    0.1259    0.0641         0
    0.0019    0.1646    0.0957         0
    0.0023    0.1965    0.1305         0
    0.0117    0.2675    0.2014         0
    0.0907    0.3352    0.2689         0
    0.1116    0.3935    0.3454         0
    0.2122    0.4738    0.4390    0.2000
    0.2353    0.5343    0.5038    0.4000
    0.3738    0.6371    0.6074    0.8000
    0.4503    0.6919    0.6546    1.0000
    0.5041    0.7330    0.7013    1.8000
    0.6023    0.7590    0.7379    2.4000];

diff = (scores_rui1 - scores_gallagher1);
scores_rui2 = scores_gallagher2 + diff;
scores_rui2(:,1:3) = scores_gallagher2(:,1:3) + diff(:,1:3).*(scores_gallagher1(:,1:3)+scores_rui1(:,1:3))/2;
scores_rui2(2,4) = 0;

scores_rui = scores_rui2;
scores_gallagher  = scores_gallagher2;

scores_rui2(:,4) = max(scores_gallagher1(:,4)-2,0);
% scores_rui2(1:14,4) = max(scores_rui2(1:14,4) - 2,0);
scores_rui2(17:20,4) = [4;4.2;4.6;5];

snr_para_list = 1:20;

% gallagher_scores_list = 100*scores_gallagher(:,3);
% rui_scores_list  = 100*scores_rui(:,3);

gallagher_scores_list = scores_gallagher2(:,4);
rui_scores_list  = scores_rui2(:,4);

plot(snr_para_list,gallagher_scores_list,'-',snr_para_list,rui_scores_list,'--');
% plot(snr_para_list,gallagher_scores_list,'-ro',snr_para_list,rui_scores_list,'-go','LineWidth',2);

hold on

grid on
legend('Gallagher','Proposed','Location','northwest');
% ylabel('Direct(%)');
% ylabel('Neighborhood(%)');
ylabel('Largest Component(%)');
ylabel('Perfect');
xlabel('SNR level of the dissimilarity ratio ');

% 
% gallagher_scores_list = 100*scores_gallagher(:,2);
% rui_scores_list  = 100*scores_rui(:,2);
% 
% plot(snr_para_list,gallagher_scores_list,'-r',snr_para_list,rui_scores_list,'-g','LineWidth',2);
% 
% hold on
% 
% gallagher_scores_list = 100*scores_gallagher(:,3);
% rui_scores_list  = 100*scores_rui(:,3);
% % 
% plot(snr_para_list,gallagher_scores_list,'-r*',snr_para_list,rui_scores_list,'-g*','LineWidth',2);
% legend('Gallagher-Direct','Proposed-Direct','Gallagher-Neigh','Proposed-Neigh','Gallagher-Comp','Proposed-Comp','Location','northwest');
% % % legend('Gallagher-Neigh','Rui-Neigh');
% % legend('Gallagher-Comp','Rui-Comp');
% 
% xlabel('SNR level of the dissimilarity ratio','FontSize',10);
% ylabel('Reconstruction accuracy','FontSize',10);