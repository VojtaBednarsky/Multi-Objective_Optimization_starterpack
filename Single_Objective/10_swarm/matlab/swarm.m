function g = swarm( G, I)

dt = 0.1;
c1 = 1.49;                    % personal scaling factor
c2 = 1.49;                    % global scaling factor

x  = zeros( I, 3);            % pozice v�el
p  = zeros( I, 3);            % osobn� optimum v�el

x(:,1:2) = 4*rand(I,2) - ones(I,2);   % po��te�n� pozice v�el
v        = rand(I,2);                 % po��te�n� rychlost v�el

p(:,1:2) = x(:,1:2);          % po��te�n� osobn� optimum = aktu�ln�
p(:,3)   = 1e+6;              % po��te�n� chyba

e    = zeros( G+1, 1);        % �asov� pr�b�h glob�ln� chyby
e(1) = 1e+6;                  % chyba "p�ed startem"

for m=1:G               % +++ HLAVN� ITERA�N� SMY�KA +++
  
  x(:,3) = rb( x(:,1), x(:,2));       % kriteri�ln� funkce

  for n=1:I                      % aktualizace osobn�ch optim v�el
    if x(n,3)<p(n,3)
      p(n,:) = x(n,:);
    end
  end
  
  [e(m+1),ind] = min( p(:,3));   % glob�ln� nejni��� chyba
  if e(m+1)<e(m)                 % p�i poklesu glob�ln� nejni��� chyby
    g = p( ind, 1:2);            % ulo� sou�adnice glob�ln� nejlep�� v�ely
  end
  
  w = 0.5*(G-m)/G + 0.4;         % nov� setrva�n� v�ha
  
  for n=1:I                                % nov� rychlost
    v(n,:)   = w*v(n,:) + c1*rand()*( p(n,1:2)-x(n,1:2));
    v(n,:)   = v(n,:)   + c2*rand()*( g(1,1:2)-x(n,1:2));
    x(n,1:2) = x(n,1:2) + dt*v(n,:);       % nov� pozice
    if x(n,1) >  3, x(n,1) =  3; end       % absorp�n� st�ny
    if x(n,1) < -1, x(n,1) = -1; end
    if x(n,2) >  3, x(n,2) =  3; end
    if x(n,2) < -1, x(n,2) = -1; end
  end
  
end
plot( e(2:G+1,1));                % vykreslen� pr�b�hu chyby