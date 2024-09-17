function sdn( alpha)

% Steepest Descent Numerical

M = 10000;
x = [ -1; +1];

h = 1e-3;
% alpha = 1e-3;

for m=1:M
  X1(1,1) = rb( [x(1,1) + h/2; x(2,1)]);
  X1(2,1) = rb( [x(1,1) - h/2; x(2,1)]);
  X2(1,1) = rb( [x(1,1); x(2,1) + h/2]);
  X2(2,1) = rb( [x(1,1); x(2,1) - h/2]);
  g(1,1) = (X1(1,1) - X1(2,1)) / h;
  g(2,1) = (X2(1,1) - X2(2,1)) / h;
  x    = x - alpha*g;
  out(m,:) = x';
end

figure; plot( 1:M, out(:,1), 'r-', 1:M, out(:,2), 'b-');