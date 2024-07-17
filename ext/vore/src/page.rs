use magnus::{prelude::*, RModule};

pub fn init(m_vore: RModule) -> Result<(), magnus::Error> {
    let c_page = m_vore
        .define_class("Page", magnus::class::object())
        .expect("cannot define class Vore::Page");

    Ok(())
}
