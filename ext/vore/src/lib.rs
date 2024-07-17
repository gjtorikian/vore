use magnus::{Error, Ruby};

pub mod page;
pub mod website;

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let m_vore = ruby.define_module("Vore")?;
    website::init(m_vore).expect("cannot define Vore::Website class");
    page::init(m_vore).expect("cannot define Vore::Page class");

    Ok(())
}
