function new_a( M)

x = -2;
y = 2;

h = 1e-3;

for m=1:M
    gx = (rb([x+h;y]) - rb([x-h;y])) / (2*h);
    gy = (rb([x;y+h]) - rb([x;y-h])) / (2*h);
    
    Hxx = (rb([x+2*h;y]) - 2*rb([x;y]) + rb([x-2*h;y])) / (4*h^2);
    Hxy = (rb([x+h;y+h]) - rb([x-h;y+h]) - rb([x+h;y-h]) + rb([x-h;y-h])) / (4*h^2);
    Hyx =  Hxy;
    Hyy = (rb([x;y+2*h]) - 2*rb([x;y]) + rb([x;y-2*h])) / (4*h^2);
    
    a = [x;y] - inv([Hxx,Hxy;Hyx,Hyy])*[gx;gy];
    
    x = a(1,1);
    y = a(2,1);
    xs(m) = x;
    ys(m) = y;
end

plot( 1:M, xs, 'r', 1:M, ys, 'b');