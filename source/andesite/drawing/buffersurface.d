module andesite.drawing.buffersurface;
import andesite.imp.cairo;
import andesite.drawing.color;
import gdk.Pixbuf;
import std.math;

/**
	Reimplementation of elementary's BufferSuface.vala
**/

public class BufferSuface {
private:
	Surface surface_;
	Context context_;

public:

	/**
		Public properties
	**/
	/// Width of buffer surface in pixels.
	int width;

	/// Height of buffer surface in pixels.
	int height;



	/**
		Getters/Setters
	**/
	/// Gets the backend surface.
	@property Surface surface() {
		if (surface_ is null) surface_ = ImageSurface.create(CairoFormat.ARGB32, width, height);
		return surface_;
	}

	/// Sets the backend surface.
	@property void surface(Surface s) {
		surface_ = s;
	}

	/// Gets the backend context.
	@property Context context() {
		if (context_ is null) context_ = Context.create(surface_);
		return context_;
	}

	/// Sets the backend context.
	@property void context(Context c) {
		context_ = c;
	}

	/**
		Constructors
	**/

	/// Constructs a BufferSurface
	this()(int width, int height) if (width >= 0 && height >= 0) {
		this.width = width;
		this.height = height;
	}

	/// Constructs a BufferSurface based on a surface
	this()(int width, int height, Surface model) if (model !is null) {
		this(width, height);
		surface_ = Surface.createSimilar(model, CairoContent.COLOR_ALPHA, width, height);
	}

	/// Constructs a BufferSurface based on another BufferSuface
	this()(int width, int height, BufferSuface model) if (model !is null) {
		this(width, height);
		surface_ = Surface.createSimilar(model.surface, CairoContent.COLOR_ALPHA, width, height);
	}

	/**
		Methods
	**/

	/// Clears internal cairo surface.
	void clear() {
		context_.save();

		context_.setSourceRgba(0, 0, 0, 0);
		context_.setOperator(CairoOperator.SOURCE);
		context_.paint();

		context_.restore();
	}

	/// Creates a pixel buffer from internal cairo surface.
	Pixbuf loadToPixbuf() {
		ImageSurface imageSurface = ImageSurface.create(CairoFormat.ARGB32, width, height);
		Context cr = Context.create(imageSurface);

		cr.setOperator(CairoOperator.SOURCE);
		cr.setSourceSurface(surface_, 0, 0);
		cr.paint();

		int width = imageSurface.getWidth();
		int height = imageSurface.getHeight();

		// create pixel buffer and fill with transparent pixels.
		Pixbuf pb = new Pixbuf(GdkColorspace.RGB, true, 8, width, height);
		pb.fill(0x00000000);

		ubyte* data = imageSurface.getData();
		ubyte* pixels = cast(ubyte*)pb.getPixels();

		int len = width*height;

		if (imageSurface.getFormat == CairoFormat.ARGB32) {
			foreach(i; 0 .. len) {
				if (data[3] > 0) {
					pixels[0] = cast(ubyte)(data[2]*255 / data[3]);
					pixels[1] = cast(ubyte)(data[1]*255 / data[3]);
					pixels[2] = cast(ubyte)(data[0]*255 / data[3]);
					pixels[3] = data[3];
				}

				pixels += 4;
				data += 4;
			}
		} else if (imageSurface.getFormat == CairoFormat.RGB24) {
			foreach(i; 0 .. len) {
				pixels[0] = data[2];
				pixels[1] = data[1];
				pixels[2] = data[0];
				pixels[3] = data[3];

				pixels += 4;
				data += 4;
			}
		}

		return pb;
	}

	Color averageColor() {
		float rTotal = 0;
		float gTotal = 0;
		float bTotal = 0;

		int w = width;
		int h = height;

		ImageSurface original = ImageSurface.create(CairoFormat.ARGB32, w, h);
		Context ctx = Context.create(original);

		ctx.setOperator(CairoOperator.SOURCE);
		ctx.setSourceSurface(surface_, 0, 0);
		ctx.paint();

		ubyte* data = original.getData();
		int length = w * h;

		foreach (i; 0 .. length) {
			ubyte r = data[2];
			ubyte g = data[1];
			ubyte b = data[0];

			ubyte max = cast(ubyte)fmax(r, fmax(g, b));
			ubyte min = cast(ubyte)fmin(r, fmin(g, b));
			double delta = max - min;

			double sat = (delta == 0 ? 0.0 : delta / max);
			double score = 0.2 + 0.8 * sat;

			rTotal += r * score;
			gTotal += g * score;
			bTotal += b * score;

			data += 4;
		}
		
		return new Color(rTotal / ubyte.max / length, 
						gTotal / ubyte.max / length,
						bTotal / ubyte.max / length,
						1);
	}
}