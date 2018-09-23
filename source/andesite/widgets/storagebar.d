module andesite.widgets.storagebar;
import andesite.styleclass;
import gtk.Button;
import gtk.Label;
import gtk.Grid;
import gtk.Image;
import gtk.Box;
import gtk.Widget;
import gtk.ScrolledWindow;
import gtk.Border;
import cairo.Context;
import std.math;
import glib.Util;
import glib.Internationalization;
import std.xml;
import std.stdio;


public enum ItemDescription {
	Other = "files",
	Audio = "audio",
	Video = "video",
	Photo = "photo",
	App = "app",
	Files = Other
}

public class StorageBar : Box {
private:
	ulong storage_ = 0;
	ulong totalUsage_ = 0;

	Label descriptionLabel;
	FillBlock[int] blocks;
	int index;
	Box fillblockBox;
	Box legendBox;
	FillBlock freeSpace;
	FillBlock usedSpace;

	void sizeallocFunc(Allocation alloc, Widget w) {
		double lostSize = 0;
		int currentX = alloc.x;
		foreach (i; 0 .. blocks.length) {
			FillBlock block = blocks[cast(int)i];
			if (block is null || !block.isVisible) continue;

			Allocation newAlloc = Allocation();

			newAlloc.x = currentX;
			newAlloc.y = alloc.y;
			double width = ((cast(double)alloc.width) * cast(double)block.size / cast(double)storage) + lostSize;
			lostSize -= cast(int)width.trunc;
			newAlloc.width = cast(int)width.trunc;
			newAlloc.height = alloc.height;
			block.sizeAllocateWithBaseline(newAlloc, block.getAllocatedBaseline);

			lostSize = width - newAlloc.width;
			currentX += newAlloc.width;
		}
	}

public:

	@property ulong storage() {
		return storage_;
	}

	@property void storage(ulong val) {
		storage_ = val;
		updateSizeDescription();
	}

	@property ulong totalUsage() {
		return totalUsage_;
	}

	@property void totalUsage(ulong val) {
		totalUsage_ = val;
		updateSizeDescription();
	}

	@property int innerMarginSizes() {
		return fillblockBox.getMarginStart();
	}

	@property void innerMarginSizes(int val) {
		fillblockBox.setMarginStart(val);
		fillblockBox.setMarginEnd(fillblockBox.getMarginStart);
	}

	this(ulong storage, ulong totalUsage = 0) {
		super(null);
		setOrientation(Orientation.VERTICAL);
		
		descriptionLabel = new Label("");
		descriptionLabel.setHexpand(true);
		descriptionLabel.setMarginTop(6);

		getStyleContext.addClass(StyleClass.StorageBar);
		
		fillblockBox = new Box(Orientation.HORIZONTAL, 0);
		fillblockBox.getStyleContext.addClass(STYLE_CLASS_TROUGH);
		fillblockBox.setHexpand(true);

		this.innerMarginSizes(12);
		
		legendBox = new Box(Orientation.HORIZONTAL, 12);
		legendBox.setHexpand(true);
		legendBox.setVexpand(true);

		Box legendCenterBox = new Box(Orientation.HORIZONTAL, 0);
		legendCenterBox.setCenterWidget(legendBox);

		auto legendScrolled = new ScrolledWindow();
		GtkPolicyType tp;
		GtkPolicyType tpy;
		legendScrolled.getPolicy(tp, tpy);
		legendScrolled.setPolicy(tp, PolicyType.NEVER);
		legendScrolled.setHexpand(true);
		legendScrolled.add(legendCenterBox);

		Grid grid = new Grid();
		grid.attach(legendScrolled, 0, 0, 1, 1);
		grid.attach(fillblockBox, 0, 1, 1, 1);
		grid.attach(descriptionLabel, 0, 2, 1, 1);
		setCenterWidget(grid);

		fillblockBox.addOnSizeAllocate(&this.sizeallocFunc);
		createDefaultBlocks();
	}

	void createDefaultBlocks() {
		import std.algorithm.sorting;
		ItemDescription[] seq = [
			ItemDescription.Files, 
			ItemDescription.Audio,
			ItemDescription.Video,
			ItemDescription.Photo,
			ItemDescription.App];
		seq.sort!("a.stringof < b.stringof");

		foreach (description; seq) {
			auto fillBlock = new FillBlock(description, 0);
			fillblockBox.add(fillBlock);
			legendBox.add(fillBlock.legendItem);
			blocks[index] = fillBlock;
		}

		freeSpace = new FillBlock(ItemDescription.Files, storage);
		usedSpace = new FillBlock(ItemDescription.Files, totalUsage);
		freeSpace.getStyleContext.addClass("empty-block");
		freeSpace.getStyleContext.removeClass("files");
		usedSpace.getStyleContext.removeClass("files");
		blocks[this.index++] = usedSpace;
		blocks[this.index++] = freeSpace;
		fillblockBox.add(usedSpace);
		fillblockBox.add(freeSpace);

		updateSizeDescription();
	}

	void updateSizeDescription() {
		ulong userSize = 0;
		foreach(FillBlock block; blocks) {
			if (!block.isVisible || block == freeSpace || block == usedSpace)
				continue;
			
			userSize += block.size;
		}

		ulong free;
		if (userSize > totalUsage) {
			free = storage - userSize;
			usedSpace.size = 0;
		} else {
			free = storage - totalUsage;
			usedSpace.size = totalUsage - userSize;
		}

		freeSpace.size = free;
		// TODO: Nationalization!
		import std.format;
		descriptionLabel.setLabel("%s free out of %s".format(
			Util.formatSizeFull(free, FormatSizeFlags.IEC_UNITS),
			Util.formatSizeFull(storage, FormatSizeFlags.IEC_UNITS)));
	}

	void updateBlockSize(ItemDescription descr, ulong size) {
		foreach(FillBlock block; blocks) {
			if (block.description == descr) {
				block.size = size;
				updateSizeDescription();
				return;
			}
		}
	}
}

public string getName(ItemDescription description) {
	// TODO: Handle translation
	import std.string, std.conv;
	return (description.stringof[0]).text.toUpper ~ description.stringof[1..$];
}

public class FillBlock : FillRound {
private:
	ulong size_ = 0;
	Grid legendItem_;

public:
	ItemDescription description;
	Label nameLabel;
	Label sizeLabel;
	FillRound legendFill;

	@property Grid legendItem() {
		return legendItem_;
	}

	@property ulong size() {
		return size_;
	}

	@property void size(ulong val) {
		size_ = val;
		if (size_ == 0) {
			this.setNoShowAll(true);
			this.setVisible(false);
			legendItem_.setNoShowAll(true);
			legendItem_.setVisible(false);
		} else {
			this.setNoShowAll(false);
			this.setVisible(true);
			legendItem_.setNoShowAll(false);
			legendItem_.setVisible(true);
			sizeLabel.setLabel(Util.formatSizeFull(size_, GFormatSizeFlags.IEC_UNITS));
			queueResize();
		}
	}

	this(ItemDescription description, ulong size) {
		showAll();
		legendItem_ = new Grid();
		legendItem_.setColumnSpacing(6);
		nameLabel = new Label("");
		nameLabel.setHalign(Align.START);
		nameLabel.setUseMarkup(true);
		sizeLabel = new Label("");
		sizeLabel.setHalign(Align.START);
		legendFill = new FillRound();
		legendFill.getStyleContext.addClass("legend");
		auto legendbox = new Box(Orientation.VERTICAL, 0);
		legendbox.setCenterWidget(legendFill);
		legendItem_.attach(legendbox, 0, 0, 1, 2);
		legendItem_.attach(nameLabel, 1, 0, 1, 1);
		legendItem_.attach(sizeLabel, 1, 1, 1, 1);

		string clas = description;
		if (clas !is null) {
			getStyleContext.addClass(clas);
			legendFill.getStyleContext.addClass(clas);
		}

		import std.format;
		nameLabel.setLabel(q{<b>%s</b>}.format(description.getName.encode));
	}
}

public class FillRound : Widget {
public:
	this() {
		super(null);
		setHasWindow(false);
		getStyleContext.addClass("fill-block");
		setHexpand(true);
		setVexpand(true);
	}

	override void draw(Context ctx) {
		auto width = getAllocatedWidth();
		auto height = getAllocatedHeight();
		auto context = getStyleContext();

		context.renderBackground(context, ctx, 0, 0, width, height);
		context.renderFrame(context, ctx, 0, 0, width, height);
	}

	override void getPreferredWidth(out int minWidth, out int natWidth) {
		super.getPreferredWidth(minWidth, natWidth);
		auto context = getStyleContext();
		Border padding;
		context.getPadding(getStateFlags(), padding);
		minWidth = cast(int)fmax(padding.left + padding.right, minWidth);
		minWidth = cast(int)fmax(1, minWidth);
		natWidth = cast(int)fmax(minWidth, natWidth);
	}

	override void getPreferredHeight(out int minHeight, out int natHeight) {
		super.getPreferredWidth(minHeight, natHeight);
		auto context = getStyleContext();
		Border padding;
		context.getPadding(getStateFlags(), padding);
		minHeight = cast(int)fmax(padding.top + padding.bottom, minHeight);
		minHeight = cast(int)fmax(1, minHeight);
		natHeight = cast(int)fmax(minHeight, natHeight);
	}
}
