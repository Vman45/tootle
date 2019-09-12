using Gtk;
using Gdk;

public class Tootle.Widgets.Avatar : EventBox {

	public string? url { get; set; }
	public int size { get; set; default = 48; }
	
	private Cache.Reference? cached;

	construct {
		get_style_context ().add_class ("avatar");
		notify["url"].connect (on_url_updated);
		Screen.get_default ().monitors_changed.connect (on_redraw);
		on_url_updated ();
	}

	public Avatar (int size = this.size) {
		Object (size: size);
	}
	
	~Avatar () {
		notify["url"].disconnect (on_url_updated);
		Screen.get_default ().monitors_changed.disconnect (on_redraw);
		cache.unload (cached);
	}
	
	private void on_url_updated () {
		cached = null;
		on_redraw ();
		cache.load (url, on_cache_result);
	}
	
	private void on_cache_result (Cache.Reference? result) {
		cached = result;
		on_redraw ();
	}
	
	public int get_scaled_size () {
		return size * get_scale_factor ();
	}
	
	private void on_redraw () {
		set_size_request (get_scaled_size (), get_scaled_size ());
		queue_draw_area (0, 0, size, size);
	}
	
	public override bool draw (Cairo.Context ctx) {
		var w = get_allocated_width ();
		var h = get_allocated_height ();
		var style = get_style_context ();
		var border_radius = style.get_property (Gtk.STYLE_PROPERTY_BORDER_RADIUS, style.get_state ()).get_int ();
        
        ctx.set_source_rgb (0,0,0);
        Drawing.draw_rounded_rect (ctx, 0, 0, w, h, border_radius);
	
		if (cached != null) {
			var pixbuf = cached.item.scale_simple (get_scaled_size (), get_scaled_size (), InterpType.BILINEAR);
			Gdk.cairo_set_source_pixbuf (ctx, pixbuf, 0, 0);
		}
	
		ctx.fill ();
		return Gdk.EVENT_STOP;
	}

}