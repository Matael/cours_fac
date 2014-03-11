clc;clear all;close all;


rho=1.2;    %masse volumique de l'air
c0=344;     %c�l�rit� du son

r=1;        %distance source-microphone

%%%%%%%%%%%%%%%%%%
% ampli audio %%%%
%%%%%%%%%%%%%%%%%%
Ug=4;       % tension 
Rg=0;       % r�sistance de sortie de l'ampli

%%%%%%%%%%%%%%%%%%
% enceinte %%%%%%%
%%%%%%%%%%%%%%%%%%

V_enceinte=20e-3;
C_enceinte=V_enceinte./(rho.*c0.^2);
L_event=10e-3;
r_event=3e-3;
S_event=pi.*r_event.^2
M_event=rho.*L_event./S_event;
f_res_bass_reflex=1./(2.*pi)./sqrt(M_event.*C_enceinte)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% bande de fr�quence d'analyse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freq=[1:2:5000];
omega=2.*pi.*freq;
k0=omega./c0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% caract�ristique constructeur AUDAX HP170 MO %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a=0.085;        % rayon membrane
S=pi.*a.^2;     % surface membrane
Re=6.2;         % r�sitance bobine
Le=0.57e-3;     % inductance bobine
Qms=3.12;
Qes=0.90;
Vas=16.34e-3;

fs=62.3;        % fr�quence de r�sonance �quipage mobile


Cm=Vas./(rho.*c0.^2.*S.^2);
Mm=1./(4.*pi.^2.*Cm.*fs.^2);
Rm=1./(2.*pi.*fs.*Cm.*Qms);
Zm=Rm+j.*Mm.*omega+1./(j.*Cm.*omega);
Bl=sqrt(2.*pi.*fs.*Re.*Mm./Qes);
Qts=Qms.*Qes./(Qms+Qes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Charges acoustiques avant et arri�re %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Z_ray_HP=rho.*c0./S.*(1-besselj(1,2.*k0.*a)./(k0.*a)+j.*struve(1,2.*k0.*a)./(k0.*a));
Z_ray_event=rho.*c0./S_event.*(1-besselj(1,2.*k0.*r_event)./(k0.*r_event)+j.*struve(1,2.*k0.*r_event)./(k0.*r_event)); %NB: ceci est une approx car une collone fluide n'est pas un piston plan

Z_av=Z_ray_HP;                                                                                     %imp�dance de charge avant
Z_ar=(j.*M_event.*omega+Z_ray_event)./(1+j.*C_enceinte.*omega.*(j.*M_event.*omega+Z_ray_event));   %imp�dance de charge arri�re



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% param�tres �lectrom�ca vus c�t� acoustique %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Rea=(Bl./S).^2./(Rg+Re);
Cea=Le.*(S./Bl).^2;
Rma=Rm./S.^2;
Mma=Mm./S.^2;
Cma=Cm.*S.^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% param�tres �lectrom�ca vus c�t� �lectrique %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mme=Mm./Bl.^2;
Cme=Cm.*Bl.^2;
Rme=Bl.^2./Rm;
Zeav=Bl.^2./(S.^2.*Z_av);
Zear=Bl.^2./(S.^2.*Z_ar);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% imp�dance �lectrique (voir poly haut-parleurs p.5) %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Zeq=1./(j.*Mme.*omega+1./Rme+1./(j.*omega.*Cme)+1./Zeav+1./Zear);
Z_HP=Re+j.*omega.*Le+Zeq;

figure(1);
subplot(211);plot(freq,abs(Z_HP));xlabel('frequence (Hz)');ylabel('|Z_{HP}|');
subplot(212);plot(freq,angle(Z_HP));xlabel('frequence (Hz)');ylabel('Arg(Z_{HP})');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% r�ponse en fr�quence (voir transparents de cours) %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%rayonnement du HP
w_pg=1./((Rea./(j.*omega.*Cea))./(Rea+1./(j.*omega.*Cea))+Rma+j.*Mma.*omega+1./(j.*Cma.*omega)+Z_av+Z_ar);  
p_pg=sqrt(rho.*c0./(4.*pi.*r.^2).*real(Z_av)).*w_pg;                        
pg_Ug=Bl./(Rg+Re+j.*omega.*Le)./S;
w_Ug=w_pg.*pg_Ug;
p_Ug=p_pg.*pg_Ug;

%rayonnement de l'�vent
wev_pg=(1./(j.*C_enceinte.*omega))./(1./(j.*C_enceinte.*omega)+j.*M_event.*omega+Z_ray_event).*w_pg;
pev_pg=-sqrt(rho.*c0./(4.*pi.*r.^2).*real(Z_ray_event)).*wev_pg; %NB: signe moins qui traduit l'opposition de phase entre onde avant et onde arri�re
wev_Ug=wev_pg.*pg_Ug;
pev_Ug=pev_pg.*pg_Ug;

%rayonnement total (BF)
ptot_Ug=p_Ug+pev_Ug;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% r�ponse en fr�quence %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2);
subplot(211);
hold on;
semilogx(freq,20.*log10(abs(p_Ug)),'r', 'LineWidth', 2);
semilogx(freq,20.*log10(abs(pev_Ug)),'b');
semilogx(freq,20.*log10(abs(ptot_Ug)),'k');
xlabel('frequence (Hz)');
ylabel('|p(r)/U_g| (dB)');
legend('HP seul','�vent seul','bass-reflex');
subplot(212);
semilogx(freq,(angle(p_Ug)),'r',freq,(angle(pev_Ug)),'b');xlabel('frequence (Hz)');ylabel('Arg(p(r)/U_g)');
legend('HP','�vent');


Lp=20.*log10(abs(ptot_Ug)./sqrt(2).*Ug./2e-5);             % niveau de pression rayonn� en dB SPL
P_elec=0.5.*abs(Ug).^2.*real(1./Z_HP);                  % puissance �lectrique inject�e
indice=find(freq==1000);
P_elec_1k=P_elec(indice);
titre3=['niveau de pression rayonn� à',num2str(r),' m�tre, pour une puissance �lectrique de',num2str(P_elec_1k),' W (à 1kHz)'];  

figure(3);
semilogx(freq,Lp);xlabel('frequence (Hz)');ylabel('L_p (dB SPL)');
title(titre3);

vmembr_Ug=w_Ug./S;                                      % amplitude de vibration de la membrane
figure(4);
subplot(211);
semilogx(freq,abs(w_Ug),'r',freq,abs(wev_Ug),'b');xlabel('frequence (Hz)');ylabel('|v_{mb}/U_g| (m/s/V)');
subplot(212);
semilogx(freq,angle(w_Ug),'r',freq,angle(wev_Ug),'b');xlabel('frequence (Hz)');ylabel('Arg(v_{mb}/U_g)');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rendement �lectroacoustique %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P_acoust=2.*pi.*r.^2.*abs(ptot_Ug.*Ug).^2./(rho.*c0);
eta=P_acoust./P_elec;
titre5=['rendement �lectroacoustique en fonction de la fr�quence'];
figure(5);
semilogx(freq,100.*eta);xlabel('frequence (Hz)');ylabel('\eta (%)');
title(titre5);



moy=mean(eta)


% figure(1)
% print('-dpng','Zhp_bass_reflex.png');
% figure(2)
% print('-dpng','pr_ug_bass_reflex.png');
% figure(3)
% print('-dpng','Lp_1m_bass_reflex.png');
% figure(4)
% print('-dpng','Vmb_Ug_bass_reflex.png');
% figure(5)
% print('-dpng','Rendement_eac_bass_reflex.png');




