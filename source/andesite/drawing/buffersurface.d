module andesite.drawing.buffersurface;
import andesite.imp.cairo;

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

	this()(int width, int height) if (width >= 0 && height >= 0) {
		this.width = width;
		this.height = height;
	}

	this()(int width, int height, Sufrace model) if (model !is null) {
		this(width, height);
		surface = Surface.createSimilar(model, width, height);
	}
}