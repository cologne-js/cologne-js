module.exports = function(req, res) {
  res.status(404).render('404', { title: 'Oh noes! Page not found.' });
};