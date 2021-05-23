export const safe_wrapp = (p: Promise<unknown>) => p.catch(console.error)
