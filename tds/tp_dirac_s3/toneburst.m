function [t,s]=toneburst(Ncycle,Nburst,Fburst,Fe,F0);
%
% function [t,s]=toneburst(Ncycle,Nburst,Fburst,fe,f0);
%
% param�tres d'entr�e : 
%		Ncycle : nombre de p�riodes de sinus par burst
%		Nburst : nombre de bursts
%		Fburst : fr�quence de r�p�tition des bursts
%		Fe : fr�quence d'�chantillonnage en Hz
%		F0 : fr�quence du sinus en Hz
%
% param�tres de sortie : 
%       t : axe temporel
%		s : s�quence temporelle
%
% si possible choisir Fe/F0 entier...

% qqs v�rifs de base
% Ncycle/F0<=1/Fburst
if Fburst>F0/Ncycle
   return
end

N1cycletot=fix(Fe/Fburst); % nombre de points d'une p�riode enti�re (compl�t�e des z�ros)
Ntot=N1cycletot*Nburst;
t=(0:Ntot-1)/Fe;
s=zeros(1,Ntot);
Nsin=fix(Fe/F0); % nombre de points d'un cycle (sans les z�ros)
sref=sin(2*pi*F0*t(1:Ncycle*Nsin));
for k=1:Nburst
   s((k-1)*N1cycletot+1:(k-1)*N1cycletot+Ncycle*Nsin)=sref;
end



