function g = swarm( G, I)

dt = 0.1;
c1 = 1.49;                    % personal scaling factor
c2 = 1.49;                    % global scaling factor

x  = zeros( I, 3);            % pozice vèel
p  = zeros( I, 3);            % osobní optimum vèel

x(:,1:2) = 4*rand(I,2) - ones(I,2);   % poèáteèní pozice vèel
v        = rand(I,2);                 % poèáteèní rychlost vèel

p(:,1:2) = x(:,1:2);          % poèáteèní osobní optimum = aktuální
p(:,3)   = 1e+6;              % poèáteèní chyba

e    = zeros( G+1, 1);        % èasový prùbìh globální chyby
e(1) = 1e+6;                  % chyba "pøed startem"

for m=1:G               % +++ HLAVNÍ ITERAÈNÍ SMYÈKA +++
  
  x(:,3) = rb( x(:,1), x(:,2));       % kriteriální funkce

  for n=1:I                      % aktualizace osobních optim vèel
    if x(n,3)<p(n,3)
      p(n,:) = x(n,:);
    end
  end
  
  [e(m+1),ind] = min( p(:,3));   % globálnì nejnižší chyba
  if e(m+1)<e(m)                 % pøi poklesu globálnì nejnižší chyby
    g = p( ind, 1:2);            % ulož souøadnice globálnì nejlepší vèely
  end
  
  w = 0.5*(G-m)/G + 0.4;         % nová setrvaèná váha
  
  for n=1:I                                % nová rychlost
    v(n,:)   = w*v(n,:) + c1*rand()*( p(n,1:2)-x(n,1:2));
    v(n,:)   = v(n,:)   + c2*rand()*( g(1,1:2)-x(n,1:2));
    x(n,1:2) = x(n,1:2) + dt*v(n,:);       % nová pozice
    if x(n,1) >  3, x(n,1) =  3; end       % absorpèní stìny
    if x(n,1) < -1, x(n,1) = -1; end
    if x(n,2) >  3, x(n,2) =  3; end
    if x(n,2) < -1, x(n,2) = -1; end
  end
  
end
plot( e(2:G+1,1));                % vykreslení prùbìhu chyby