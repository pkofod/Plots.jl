

# TODO: there should be a distinction between an object that will manage a full plot, vs a component of a plot.
# the PlotRecipe as currently implemented is more of a "custom component"
# a recipe should fully describe the plotting command(s) and call them, likewise for updating. 
#   actually... maybe those should explicitly derive from AbstractPlot???

abstract PlotRecipe

getRecipeXY(recipe::PlotRecipe) = Float64[], Float64[]
getRecipeArgs(recipe::PlotRecipe) = ()

plot(recipe::PlotRecipe, args...; kw...) = plot(getRecipeXY(recipe)..., args...; getRecipeArgs(recipe)..., kw...)
plot!(recipe::PlotRecipe, args...; kw...) = plot!(getRecipeXY(recipe)..., args...; getRecipeArgs(recipe)..., kw...)
plot!(plt::Plot, recipe::PlotRecipe, args...; kw...) = plot!(getRecipeXY(recipe)..., args...; getRecipeArgs(recipe)..., kw...)

num_series(x::AMat) = size(x,2)
num_series(x) = 1

_apply_recipe(d::Dict; kw...) = ()

# if it's not a recipe, just do nothing and return the args
function _apply_recipe(d::Dict, args...; issubplot=false, kw...)
    if issubplot && !haskey(d, :n) && !haskey(d, :layout)
        # put in a sensible default
        d[:n] = maximum(map(num_series, args))
    end
    args
end

# # -------------------------------------------------

# function rotate(x::Real, y::Real, θ::Real; center = (0,0))
#   cx = x - center[1]
#   cy = y - center[2]
#   xrot = cx * cos(θ) - cy * sin(θ)
#   yrot = cy * cos(θ) + cx * sin(θ)
#   xrot + center[1], yrot + center[2]
# end

# # -------------------------------------------------

# type EllipseRecipe <: PlotRecipe
#   w::Float64
#   h::Float64
#   x::Float64
#   y::Float64
#   θ::Float64
# end
# EllipseRecipe(w,h,x,y) = EllipseRecipe(w,h,x,y,0)

# # return x,y coords of a rotated ellipse, centered at the origin
# function rotatedEllipse(w, h, x, y, θ, rotθ)
#   # # coord before rotation
#   xpre = w * cos(θ)
#   ypre = h * sin(θ)

#   # rotate and translate
#   r = rotate(xpre, ypre, rotθ)
#   x + r[1], y + r[2]
# end

# function getRecipeXY(ep::EllipseRecipe)
#   x, y = unzip([rotatedEllipse(ep.w, ep.h, ep.x, ep.y, u, ep.θ) for u in linspace(0,2π,100)])
#   top = rotate(0, ep.h, ep.θ)
#   right = rotate(ep.w, 0, ep.θ)
#   linex = Float64[top[1], 0, right[1]] + ep.x
#   liney = Float64[top[2], 0, right[2]] + ep.y
#   Any[x, linex], Any[y, liney]
# end

# function getRecipeArgs(ep::EllipseRecipe)
#   [(:line, (3, [:dot :solid], [:red :blue], :path))]
# end

# # -------------------------------------------------


# "Correlation scatter matrix"
# function corrplot{T<:Real,S<:Real}(mat::AMat{T}, corrmat::AMat{S} = cor(mat);
#                                    colors = :redsblues,
#                                    labels = nothing, kw...)
#   m = size(mat,2)
#   centers = Float64[mean(extrema(mat[:,i])) for i in 1:m]

#   # might be a mistake? 
#   @assert m <= 20
#   @assert size(corrmat) == (m,m)

#   # create a subplot grid, and a gradient from -1 to 1
#   p = subplot(rand(0,m^2); n=m^2, leg=false, grid=false, kw...)
#   cgrad = ColorGradient(colors, [-1,1])

#   # make all the plots
#   for i in 1:m
#     for j in 1:m
#       idx = p.layout[i,j]
#       plt = p.plts[idx]
#       if i==j
#         # histogram on diagonal
#         histogram!(plt, mat[:,i], c=:black)
#         i > 1 && plot!(plt, yticks = :none)
#       elseif i < j
#         # annotate correlation value in upper triangle
#         mi, mj = centers[i], centers[j]
#         plot!(plt, [mj], [mi],
#                    ann = (mj, mi, text(@sprintf("Corr:\n%0.3f", corrmat[i,j]), 15)),
#                    yticks=:none)
#       else
#         # scatter plots in lower triangle; color determined by correlation
#         c = RGBA(RGB(getColorZ(cgrad, corrmat[i,j])), 0.3)
#         scatter!(plt, mat[:,j], mat[:,i], w=0, ms=3, c=c, smooth=true)
#       end

#       if labels != nothing && length(labels) >= m
#         i == m && xlabel!(plt, string(labels[j]))
#         j == 1 && ylabel!(plt, string(labels[i]))
#       end
#     end
#   end

#   # link the axes
#   subplot!(p, link = (r,c) -> (true, r!=c))
# end


"Sparsity plot... heatmap of non-zero values of a matrix"
function spy{T<:Real}(z::AMat{T}; kw...)
  # I,J,V = findnz(z)
  # heatmap(J, I; leg=false, yflip=true, kw...)
  heatmap(map(zi->float(zi!=0), z); leg=false, yflip=true, kw...)
end

"Adds a+bx... straight line over the current plot"
function abline!(plt::Plot, a, b; kw...)
    plot!(plt, [extrema(plt)...], x -> b + a*x; kw...)
end

abline!(args...; kw...) = abline!(current(), args...; kw...)