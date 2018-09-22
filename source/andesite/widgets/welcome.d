module andesite.widgets.welcome;
import andesite.widgets.welcomebutton;
import andesite.styleclass;
import gtk.Grid;
import gtk.Button;
import gtk.Widget;
import gtk.Image;
import gtk.Label;
import gdk.Pixbuf;
import sev.event;
import std.algorithm;

public class WelcomeView : Grid {
private:
	Label titleLabel;
	Label subtitleLabel;

	void delegateHandlerActivated(Button b) {
		int index = cast(int)(children.length-1);
		if (activated !is null)
			activated(null, new WelcomeActivatedEventArgs(index));
	}

protected:
	Button[] children;
	Grid options;

public:
	Event activated = new Event();
	
	@property string title() {
		return titleLabel.getLabel;
	}
	
	@property void title(string title) {
		titleLabel.setLabel(title);
	}
		
	@property string subtitle() {
		return subtitleLabel.getLabel;
	}
	
	@property void subtitle(string title) {
		subtitleLabel.setLabel(title);
	}

	this(string title, string subtitle) {
		this.getStyleContext.addClass(STYLE_CLASS_VIEW);
		this.getStyleContext.addClass(StyleClass.Welcome);

		titleLabel = new Label(cast(GtkLabel*)null);
		titleLabel.setJustify(Justification.CENTER);
		titleLabel.setHexpand(true);
		titleLabel.getStyleContext.addClass(StyleClass.H1Label);

		subtitleLabel = new Label(cast(GtkLabel*)null);
		subtitleLabel.setJustify(Justification.CENTER);
		subtitleLabel.setHexpand(true);
		subtitleLabel.setLineWrap(true);
		subtitleLabel.setLineWrapMode(PangoWrapMode.WORD);

		auto subtitleLabelContext = subtitleLabel.getStyleContext();
		subtitleLabelContext.addClass(STYLE_CLASS_DIM_LABEL);
		subtitleLabelContext.addClass(StyleClass.H2Label);

		options = new Grid();
		options.setOrientation(Orientation.VERTICAL);
		options.setRowSpacing(12);
		options.setHalign(Align.CENTER);
		options.setMarginTop(24);

		Grid content = new Grid();
		content.setHexpand(true);
		content.setVexpand(true);
		content.setMarginTop(12);
		content.setMarginLeft(12);
		content.setMarginRight(12);
		content.setMarginBottom(12);
		content.setOrientation(Orientation.VERTICAL);
		content.setValign(Align.CENTER);
		content.add(titleLabel);
		content.add(subtitleLabel);
		content.add(options);

		this.add(content);
	}

	void setItemVisible(uint index, bool val) {
		if (index < children.length && is(children[index] : Widget)) {
			children[index].setNoShowAll(!val);
			children[index].setVisible(val);
		}
	}

	void removeItem(uint index) {
		if (index < children.length && is(children[index] : Widget)) {
			Widget item = children[index];
			item.destroy();
			children.remove(index);
		}
	}

	void setItemSensitivity(uint index, bool val) {
		if (index < children.length && is(children[index] : Widget)) {
			children[index].setSensitive(val);
		}
	}

	int append(string iconName, string optionText, string descriptionText) {
		Image image = new Image(cast(GtkImage*)null);
		image.setFromIconName(iconName, IconSize.DIALOG);
		return appendWithImage(image, optionText, descriptionText);
	}

	int appendWithPixbuf(Pixbuf img, string optionText, string descriptionText) {
		Image image = new Image(cast(GtkImage*)null);
		image.setFromPixbuf(img);
		return appendWithImage(image, optionText, descriptionText);
	}

	int appendWithImage(Image image, string optionText, string descriptionText) {
		WelcomeButton button = new WelcomeButton(image, optionText, descriptionText);
		children ~= button;
		options.add(button);

		button.addOnClicked(&this.delegateHandlerActivated);

		return cast(int)children.length-1;
	}

	WelcomeButton getButtonFromIndex(int index) {
		if (index >= 0 && index < children.length)
			return cast(WelcomeButton)children[index];
		
		return null;
	}
}

public class WelcomeActivatedEventArgs : EventArgs {
public:
	int index;
	this(int index) {
		this.index = index;
	}
}