% use corner function to get corner points, do homogenization
function corners = get_corners(fig)
    corners = corner(fig);
    [corner_m corner_n] = size(corners);
    corners(:, 3:3) = ones(corner_m, 1);
end