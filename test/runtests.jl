## Copyright (c) 2013 Miguel Bazdresch
##
## This file is distributed under the 2-clause BSD License.

# Gaston test framework
#
# There are two kinds of tests:
#   - Tests that should error -- things that Gaston should not allow, such as
#     building a figure with an invalid plotstyle.
#   - Tests that should succeed -- things that should work without producing
#     an error.

using Gaston
using Base.Test

@testset "Pass expected" begin
	closeall()
	# figures
	@test figure() == 1
	@test figure() == 2
	@test figure(4) == 4
	@test closefigure(4) == 4
	@test closefigure() == 2
	@test closeall() == 1
	@test closeall() == 0
	# plots
	@test plot(1:10) == 1
	@test plot(1:10,handle=2) == 2
	@test plot(1:10,handle=4) == 4
	@test closeall() == 3
	@test plot(sin.(-3:0.01:3), legend = "sine", plotstyle = "lines",
		color = "blue", marker = "ecircle", linewidth = 2, pointsize = 1.1,
		title = "test plot 1", xlabel = "x", ylabel = "y",
		box = "inside horizontal left top", axis ="loglog") == 1
	@test plot(1:10,xrange = "[2:3]") == 1
	@test plot(1:10,xrange = "[-1.1:3.4]") == 1
	@test plot(1:10,xrange = "[:3.4]") == 1
	@test plot(1:10,xrange = "[3.4:]") == 1
	@test plot(1:10,xrange = "[3.4:*]") == 1
	@test plot(1:10,xrange = "[*:3.4]") == 1
	@test plot(3,4,plotstyle="points",pointsize=3,xrange="[2.95:3.05]",yrange="[3.95:4.045]") == 1
	@test plot(rand(10).+im.*rand(10)) == 1
	@test plot(3+4im,plotstyle="points",pointsize=3,xrange="[2.95:3.05]",yrange="[3.95:4.045]") == 1
	@test begin
		err = Gaston.ErrorCoords(rand(40))
		plot(1:40,err=err,plotstyle="errorbars");
	end == 1
	@test begin
		err = Gaston.ErrorCoords(rand(40))
		plot(1:40,err=err,plotstyle="errorlines");
	end == 1
	@test begin
		err = Gaston.ErrorCoords(rand(40),rand(40))
		plot(1:40,err=err,plotstyle="errorbars");
	end == 1
	@test begin
		err = Gaston.ErrorCoords(rand(40),rand(40))
		plot(1:40,err=err,plotstyle="errorlines");
	end == 1
	@test begin
		fin = Gaston.FinancialCoords(0.1*rand(10),0.1*rand(10),0.1*rand(10),0.1*rand(10))
		plot(1:10,financial=fin,plotstyle="financebars");
	end == 1
	# histograms
	@test histogram(rand(1000)) == 1
	@test histogram(randn(1000), bins=100, norm=1, color="blue", linewidth=2,
        title="test histogram", xlabel="x", ylabel="y",
        box="inside horizontal left top") == 1
    # imagesc
	z = rand(5,6)
	@test imagesc(z,title="test imagesc 1",xlabel="xx",ylabel="yy") == 1
	@test imagesc(1:6,1:5,z,title="test imagesc 3",xlabel="xx",ylabel="yy") == 1
	# surf
	@test surf(rand(10,10)) == 1
	@test surf(rand(10,10)) == 1
	@test surf(0:9,2:11,rand(10,10)) == 1
    @test surf(0:9,2:11,(x,y)->x*y) == 1
	@test surf(0:9,2:11,(x,y)->x*y,title="test",plotstyle="pm3d") == 1
	# printfigure
	set(outputfile="$(tempdir())/gastontest")
	@test begin
		plot(1:10)
		printfigure()
	end == 1
	@test begin
		plot(1:10,handle=2)
		printfigure(handle=2,term="png")
		closefigure()
	end == 2
	@test begin
		plot(1:10)
		printfigure(term="eps")
	end == 1
	@test printfigure(term="pdf") == 1
	@test begin
		set(print_size="640,480")
		printfigure(term="svg")
	end == 1
	@test printfigure(term="gif") == 1
	# build a multiple-plot figure manually
	@test begin
		ac = Gaston.AxesConf(title="T")
		x1, exp_pdf = Gaston.hist(randn(10000),25)
		exp_pdf .= exp_pdf./(step(x1)*sum(exp_pdf))
		exp_cconf = Gaston.CurveConf(plotstyle="boxes",
									 color="blue",
									 legend="E")
		exp_curve = Gaston.Curve(x1,exp_pdf,exp_cconf)
		x2 = -5:0.05:5
		theo_pdf = @. 1/sqrt(2π)*exp((-x2^2)/2)
		theo_cconf = Gaston.CurveConf(color="black",legend="T")
		theo_curve = Gaston.Curve(x2,theo_pdf,theo_cconf)
		figure(1)
		Gaston.push_figure!(1,ac,exp_curve,theo_curve)
		Gaston.llplot()
	end == nothing
	# set
	@test set(legend="A") == nothing
	@test set(plotstyle="linespoints") == nothing
	@test set(color="red") == nothing
	@test set(marker="ecircle") == nothing
	@test set(linewidth=3) == nothing
	@test set(pointsize=3) == nothing
	@test set(title="A") == nothing
	@test set(xlabel="A") == nothing
	@test set(ylabel="A") == nothing
	@test set(zlabel="A") == nothing
	@test set(fill="solid") == nothing
	@test set(grid="on") == nothing
	@test set(terminal="x11") == nothing
	@test set(outputfile="A") == nothing
	@test set(print_color="red") == nothing
	@test set(print_fontface="A") == nothing
	@test set(print_fontscale=1) == nothing
	@test set(print_linewidth=3) == nothing
	@test set(print_size="10,10") == nothing
	closeall()
end

@testset "Failure expected" begin
	closeall()
	# figure-related
	@test_throws ErrorException figure("invalid")
	@test_throws ErrorException figure(1.0)
    @test_throws ErrorException figure(1:2)
	@test_throws ErrorException closefigure(-1)
	@test_throws ErrorException closefigure("invalid")
	@test_throws ErrorException closefigure(1.0)
	@test_throws ErrorException closefigure(1:2)
	# plot
	@test_throws AssertionError plot(0:10,0:11)
	@test_throws AssertionError plot(0:10,legend=0)
	@test_throws AssertionError plot(0:10,plotstyle="invalid")
	@test_throws AssertionError plot(0:10,marker="invalid")
	@test_throws AssertionError plot(0:10,marker=0)
	@test_throws AssertionError plot(0:10,linewidth="b")
	@test_throws AssertionError plot(0:10,linewidth=im)
	@test_throws AssertionError plot(0:10,pointsize="b")
	@test_throws AssertionError plot(0:10,pointsize=im)
	@test_throws AssertionError plot(0:10,title=0)
	@test_throws AssertionError plot(0:10,xlabel=0)
	@test_throws AssertionError plot(0:10,ylabel=0)
	@test_throws AssertionError plot(0:10,axis="invalid")
	@test_throws AssertionError plot(1:10,xrange = "2:3")
	@test_throws AssertionError plot(1:10,yrange = "ab")
	f = Gaston.FinancialCoords([1,2],[1,2],[1,2],[1,2])
	@test_throws AssertionError plot(1:10,financial=f)
	er = Gaston.ErrorCoords([0.1,0.1])
	@test_throws AssertionError plot(1:10,err=er)
	# plot!
	plot(1:10)
	@test_throws AssertionError plot!(0:10,legend=0)
	@test_throws MethodError plot!(0:10,axis="loglog")
	# imagesc
	z = rand(5,6)
	@test_throws AssertionError imagesc(1:5,1:7,z)
	# histogram
	@test_throws MethodError histogram(0:10+im*0:10)
	# set
	@test_throws AssertionError set(legend=3)
	@test_throws AssertionError set(plotstyle="A")
	@test_throws AssertionError set(color=3)
	@test_throws AssertionError set(marker="xyz")
	@test_throws AssertionError set(linewidth="A")
	@test_throws AssertionError set(pointsize="A")
	@test_throws AssertionError set(title=3)
	@test_throws AssertionError set(xlabel=3)
	@test_throws AssertionError set(ylabel=3)
	@test_throws AssertionError set(zlabel=3)
	@test_throws AssertionError set(fill="red")
	@test_throws AssertionError set(grid="xyz")
	@test_throws AssertionError set(terminal="x12")
	@test_throws AssertionError set(outputfile=3)
	@test_throws AssertionError set(print_color=3)
	@test_throws AssertionError set(print_fontface=3)
	@test_throws AssertionError set(print_fontscale="1")
	@test_throws AssertionError set(print_linewidth="3")
	@test_throws AssertionError set(print_size=10)
	closeall()
end
